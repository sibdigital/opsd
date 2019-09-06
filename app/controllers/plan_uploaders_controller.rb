#-- encoding: UTF-8

#+-tan 2019.04.25

class PlanUploadersController < ApplicationController
  require 'roo'
  require 'date'
  include PlanUploadersHelper

  def index
    @plan_uploaders = PlanUploader.all
  end

  def new
    @project = Project.find(params[:project_id])
    @plan_uploader = PlanUploader.new
    get_setting_types
  end

  def create
    @plan_uploader = PlanUploader.new(permitted_params.plan_uploader)
    @first_row_num = params[:first_row_num]

    if @plan_uploader.save

      if params[:plan_type] == 'UploadPlanType1'
        load
      else
        load_plan2
      end

      redirect_to planning_project_stages_path, notice: "Данные загружены."
    else
      render "new"
    end
  end

  def destroy
    # @plan_uploaders = Resume.find(params[:id])
    # @plan_uploaders.destroy
    # redirect_to resumes_path, notice:  "The resume #{@resume.name} has been deleted."
  end

  protected

  def load
    prepare_roo
    filename = Rails.root.join('public', @plan_uploader.name.store_path)

    #settings = PlanUploaderSetting.select('column_name, column_num, is_pk').where("table_name = 'work_packages'").order('column_num ASC').all
    settings = PlanUploaderSetting.select('column_name, column_num, is_pk').where("setting_type = 'UploadPlanType1'").order('column_num ASC').all

    row_num = @first_row_num.to_i
    rows = []
    xlsx = Roo::Excelx.new(filename)
    xlsx.each_row_streaming(offset: @first_row_num.to_i - 1) do |row|
      rr = {}
      settings.each { |setting| rr[setting.column_name] = Hash['column_name', setting.column_name, setting.column_name, row[setting.column_num].value, 'is_pk', setting.is_pk] }
      rows.push rr
    end

    @project_for_load = Project.find(params[:project_id])

    rows.each do |row|
      if row.present?
        params = {}
        row.to_h.each do |r|
          params[r[0]] = r[1][r[0]]
        end

        if params['subject'] == 0 || params['subject'] == nil || params['subject'] == ''
          next
        end

        is_new_record = false
        task = WorkPackage.where(:project_id => @project_for_load.id, :plan_num_pp => params['plan_num_pp'], :subject => params['subject'].to_s[0..250]).first_or_create! do |wp|
          is_new_record = true
          wp.subject = params['subject'].to_s[0..250]
          wp.due_date = params['due_date']
          wp.plan_num_pp = params['plan_num_pp']
          wp.description = params['description']

          if params['assigned_to_id'] == 0
            wp.assigned_to_id = nil
          end

          if (params['assigned_to_id'].present?)&&(params['assigned_to_id'] != 0)
            # fio = params['assigned_to_id'].split(' ')
            # #user = User.where(:firstname => fio[1], :lastname => fio[0], :patronymic => fio[2]).first_or_create! do |u|
            # users = User.find_by_sql("select * from users where lower(lastname)||substr(lower(firstname),1,1)||(case when patronymic is null or patronymic = '' then '' else substr(lower(patronymic),1,1) end) = '" + fio[0] + fio[1][0] + fio[2][0] + "'") do |u|
            # #users = User.find_by_sql("select * from users where lastname||substr(firstname,1,1)||(case when patronymic is null or patronymic = '' then '' else substr(patronymic,1,1) end) = '" + fio[0] + fio[1][0] + fio[2][0] + "'")
            # if users.count == 0
            #
            #   u.login = fio[0] + fio[1][0] + fio[2][0]
            #   u.login = convert(u.login.downcase, :english)
            #   #u.login = 'testuser'
            #   u.admin = 0
            #   u.status = 1
            #   u.language = Setting.default_language
            #   u.type = User
            #   u.mail_notification = Setting.default_notification_option
            #   if Setting.mail_from.index("@") != nil
            #     u.mail = u.login + Setting.mail_from.to_s[Setting.mail_from.index("@")..Setting.mail_from.size-1]
            #   else
            #     u.mail = u.login + '@example.net'
            #   end
            #   u.first_login = true
            # end
            # wp.assigned_to_id = user.id
            #
            # #добавить юзера в участника проекта
            # #project_members_path(project_id: @project_for_load, action: 'create')
            # if Member.where(user_id: user.id, project_id: @project_for_load.id).count < 1
            #   @project_for_load.add_member!(user, Role.where(name: "Ответственный за блок мероприятий").first)
            # end

            fio = params['assigned_to_id'].delete('.')
            fio = fio.split(' ')

            users = User.find_by_sql("select * from users where lastname||substr(firstname,1,1)||(case when patronymic is null or patronymic = '' then '' else substr(patronymic,1,1) end) = '" + fio[0] + fio[1][0] + fio[2][0] + "'")
            if users.count == 0
              u = User.new(language: Setting.default_language,
                           mail_notification: Setting.default_notification_option)
              u.login = fio[0] + fio[1][0] + fio[2][0]
              u.login = convert(u.login.downcase, :english)
              u.firstname = fio[1]
              u.lastname = fio[0]
              if fio[2].present?
                u.patronymic = fio[2]
              end
              u.admin = 0
              u.status = 1
              #u.language = Setting.default_language
              u.type = User
              #u.mail_notification = Setting.default_notification_option
              if Setting.mail_from.index("@") != nil
                u.mail = u.login + Setting.mail_from.to_s[Setting.mail_from.index("@")..Setting.mail_from.size-1]
              else
                u.mail = u.login + '@example.net'
              end
              u.first_login = true

              if u.save!
                wp.assigned_to_id = User.last.id
                #добавить юзера в участника проекта
                #project_members_path(project_id: @project_for_load, action: 'create')
                if Member.where(user_id: User.last.id, project_id: @project_for_load.id).count < 1
                  @project_for_load.add_member!(u, Role.where(name: "Ответственный за блок мероприятий").first)
                end
              end
            else
              wp.assigned_to_id = users[0].id
              #добавить юзера в участника проекта
              #project_members_path(project_id: @project_for_load, action: 'create')
              if Member.where(user_id: users[0].id, project_id: @project_for_load.id).count < 1
                @project_for_load.add_member!(users[0], Role.where(name: "Ответственный за блок мероприятий").first)
              end
            end

          end

          if params['control_level_id'].present?
            # find control_level
          end

          if params['start_date'].present?
            if params['start_date'] == Date.parse('1899-12-30')
              wp.start_date = @project_for_load.created_on
            else
              wp.start_date  = Date.parse(params['start_date'].to_s)
            end
          else
            params['start_date'] = @project_for_load.created_on
          end

          wp.project_id = @project_for_load.id
          wp.type_id = Type.find_by(name: I18n.t(:default_type_task)).id
          wp.status_id = Status.default.id
          wp.plan_type = 'execution'
          wp.author_id = User.current.id
          wp.position = 1
          wp.priority_id = IssuePriority.default.id
        end

        # тут надо обновление записи с занесением в журнал
        if !is_new_record

          if params['assigned_to_id'] == 0
            params['assigned_to_id'] = nil
          end

          if (params['assigned_to_id'].present?)&&(params['assigned_to_id'] != 0)
            fio = params['assigned_to_id'].split(' ')
            #user = User.find_or_create_by(firstname: fio[1], lastname: fio[0], patronymic: fio[2]) do |u|
            user = User.where(:firstname => fio[1], :lastname => fio[0], :patronymic => fio[2]).first_or_create! do |u|
              u.login = fio[0] + fio[1][0] + fio[2][0]
              u.login = convert(u.login.downcase, :english)
              u.admin = 0
              u.status = 1
              u.language = Setting.default_language
              u.type = User
              u.mail_notification = Setting.default_notification_option
              if Setting.mail_from.index("@") != nil
                u.mail = u.login + Setting.mail_from.to_s[Setting.mail_from.index("@")..Setting.mail_from.size-1]
              else
                u.mail = u.login + '@example.net'
              end
              u.first_login = true
            end
            params['assigned_to_id'] = user.id

            #добавить юзера в участника проекта
            #project_members_path(project_id: @project_for_load, action: 'create')
            if Member.where(user_id: user.id, project_id: @project_for_load.id).count < 1
              @project_for_load.add_member!(user, Role.where(name: "Участник").first)
            end

          end

          if params['control_level_id'].present?
            # find control_level
          end

          if params['start_date'].present?
            if params['start_date'] == Date.parse('1899-12-30')
              params['start_date'] = @project_for_load.created_on
            else
              params['start_date'] = Date.parse(params['start_date'].to_s)
            end
          else
            params['start_date'] = @project_for_load.created_on
          end

          params['project_id'] = @project_for_load.id
          params['type_id'] = Type.find_by(name: I18n.t(:default_type_task)).id
          params['status_id'] = Status.default.id # find_by(name: I18n.t(:default_status_new))
          params['plan_type'] = 'execution'
          params['author_id'] = User.current.id
          params['position'] = 1
          params['priority_id'] = IssuePriority.default.id

          WorkPackage.update(task.id, params)
        end

        # ищем id родителя
        plan_num_pp = params['plan_num_pp'].to_s
        if !plan_num_pp.rindex(".").nil?
          plan_num_pp = plan_num_pp[0..plan_num_pp.rindex(".")]
          plan_num_pp = plan_num_pp[0..plan_num_pp.size-2]
          parent_id = WorkPackage.where(project_id: @project_for_load.id, plan_num_pp: plan_num_pp).first.id

          # добавляем связи иерархии
          if parent_id.present?
            Relation.find_or_create_by(from_id: parent_id, to_id: task.id) do |rel|
              rel.from_id = parent_id
              rel.to_id = task.id
              rel.hierarchy = 1
            end
          end
        end
      end
    end
  end


  # загрузка плана "Контрольные точки" из электр-го бюджета
  def load_plan2
    prepare_roo
    filename = Rails.root.join('public', @plan_uploader.name.store_path)

    #settings = PlanUploaderSetting.select('column_name, column_num, is_pk').where("table_name = 'work_packages'").order('column_num ASC').all
    settings = PlanUploaderSetting.select('column_type, column_name, column_num, is_pk').where("setting_type = 'UploadPlanType2'").order('column_num ASC').all

    result = ""
    result_value = ""
    point = ""

    row_num = 2  # @first_row_num.to_i
    rows = []
    xlsx = Roo::Excelx.new(filename)
    xlsx.each_row_streaming(offset: 1) do |row|
      rr = {}

      #settings.each { |setting| rr[setting.column_name] = Hash['column_name', setting.column_name, setting.column_name, row[setting.column_num].value, 'is_pk', setting.is_pk] }
      col_num = {}
      settings.each { |setting| col_num[setting.column_name] = setting.column_num }

      if row[0].value.present? #Результат
        result = row[0].value
        result_value = ""
        point = ""
      else
        if row[1].value.present? #Значение результата
          result_value = row[1].value
        else
          if row[2].present? #Контрольная точка
            point = row[2].value
          else #Мероприятие
            rr = Hash["result", result,
                           "result_value", result_value,
                           "point", point,
                           "work", row[col_num['subject']].value, #row[4].value,
                           "desc", row[col_num['description']].value, #row[7].value,
                           "assigned_to", row[col_num['assigned_to_id']].value, #row[5].value,
                           "start_date", row[col_num['start_date']].value, #row[8].value,
                           "due_date", row[col_num['due_date']].value  #row[9].value]
                  ]
            rows.push rr
          end
        end
      end

    end

    puts "Row count: " + rows.count.to_s

    @project_for_load = Project.find(params[:project_id])

    insert_count = 0
    break_count = 0

    rows.each do |row|
      if row['work'].to_s[0..250] == "Мероприятия по контрольной точке отсутствуют"
        break_count += 1
        next
      end

      is_new_record = false
      task = WorkPackage.where(:project_id => @project_for_load.id,
                               :subject => row['work'].to_s[0..250],
                               :start_date => row['start_date'],
                               :due_date => row['due_date']
              )
              .first_or_initialize do |wp|
        is_new_record = true
        wp.subject = row['work'].to_s[0..250]
        wp.due_date = row['due_date']
        wp.description = row['desc']
        if row['assigned_to'] == 0
          wp.assigned_to_id = nil
        end

        if (row['assigned_to'].present?)&&(row['assigned_to'] != 0)
          fio = row['assigned_to'].delete('.')
          fio = fio.split(' ')

          users = User.find_by_sql("select * from users where lastname||substr(firstname,1,1)||(case when patronymic is null or patronymic = '' then '' else substr(patronymic,1,1) end) = '" + fio[0] + fio[1][0] + fio[2][0] + "'")
          if users.count == 0
            u = User.new(language: Setting.default_language,
                         mail_notification: Setting.default_notification_option)
            u.login = fio[0] + fio[1][0] + fio[2][0]
            u.login = convert(u.login.downcase, :english)
            u.firstname = fio[1]
            u.lastname = fio[0]
            if fio[2].present?
              u.patronymic = fio[2]
            end
            u.admin = 0
            u.status = 1
            #u.language = Setting.default_language
            u.type = User
            #u.mail_notification = Setting.default_notification_option
            if Setting.mail_from.index("@") != nil
              u.mail = u.login + Setting.mail_from.to_s[Setting.mail_from.index("@")..Setting.mail_from.size-1]
            else
              u.mail = u.login + '@example.net'
            end
            u.first_login = true

            if u.save!
              wp.assigned_to_id = User.last.id
              #добавить юзера в участника проекта
              #project_members_path(project_id: @project_for_load, action: 'create')
              if Member.where(user_id: User.last.id, project_id: @project_for_load.id).count < 1
                @project_for_load.add_member!(u, Role.where(name: "Ответственный за блок мероприятий").first)
              end
            end
          else
            wp.assigned_to_id = users[0].id
            #добавить юзера в участника проекта
            #project_members_path(project_id: @project_for_load, action: 'create')
            if Member.where(user_id: users[0].id, project_id: @project_for_load.id).count < 1
              @project_for_load.add_member!(users[0], Role.where(name: "Ответственный за блок мероприятий").first)
            end
          end
        end

        if row['start_date'].present?
          if row['start_date'] == Date.parse('1899-12-30')
            wp.start_date = @project_for_load.created_on
          else
            wp.start_date  = Date.parse(row['start_date'].to_s)
          end
        else
          row['start_date'] = @project_for_load.created_on
        end

        wp.project_id = @project_for_load.id
        wp.type_id = Type.find_by(name: I18n.t(:default_type_milestone)).id
        wp.status_id = Status.default.id
        wp.plan_type = 'execution'
        wp.author_id = User.current.id
        wp.position = 1
        wp.priority_id = IssuePriority.default.id

        # сохраняем без валидации
        if wp.save(validate: false)
          insert_count += 1
        else
          puts row['work']
        end
      end
    end

    puts "Insert count: " + insert_count.to_s
    puts "Break count: " + break_count.to_s
  end


  def prepare_roo
    Roo::Excelx::Cell::Number.module_eval do
      def create_numeric(number)
        return number if Roo::Excelx::ERROR_VALUES.include?(number)

        case @format
        when /%/
          Float(number)
        when /\.0/
          Float(number)
        else
          number.include?('.') || (/\A[-+]?\d+E[-+]?\d+\z/i =~ number) ? Float(number) : number.to_s.to_i
        end
      end
    end
  end


  private

  def get_setting_types
    @settings_types = []
    @plan_uploader_settings_types = PlanUploaderSetting.select(:setting_type).group('setting_type').order('setting_type asc').all
    @plan_uploader_settings_types.each do |setting|
      @settings_types << [setting.setting_type, setting.setting_type]
    end
    @settings_types
  end

  #
  # def new_member(user_id)
  #   Member.new(permitted_params.member).tap do |member|
  #     member.user_id = user_id if user_id
  #   end
  # end

end
