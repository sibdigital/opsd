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

    @plan_uploader.status = 1
    @plan_uploader.upload_at = DateTime.current

    if @plan_uploader.save

      case params[:plan_type]
      when 'UploadPlanType1'
        load
        redirect_to planning_project_stages_path, notice: "Данные загружены."
      when 'UploadPlanType2'
        #load_plan2
        load_plan2_v2
        redirect_to planning_project_stages_path, notice: "Данные загружены."
      when 'UploadPlanType6'
        load_msproject
        redirect_to planning_project_stages_path, notice: "Данные загружены."
      else
        flash[:notice] = "Неизвестный тип плана. Данные не загружены."
        render "new"
      end

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

  # загрузка общего плана из ЭБ
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

    puts "Row count: " + rows.count.to_s

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

            wp.assigned_to_id = add_user(fio)

            # users = User.find_by_sql("select * from users where lastname||substr(firstname,1,1)||(case when patronymic is null or patronymic = '' then '' else substr(patronymic,1,1) end) = '" + fio[0] + fio[1][0] + fio[2][0] + "'")
            # if users.count == 0
            #   u = User.new(language: Setting.default_language,
            #                mail_notification: Setting.default_notification_option)
            #   u.login = fio[0] + fio[1][0] + fio[2][0]
            #   u.login = convert(u.login.downcase, :english)
            #   u.firstname = fio[1]
            #   u.lastname = fio[0]
            #   if fio[2].present?
            #     u.patronymic = fio[2]
            #   end
            #   u.admin = 0
            #   u.status = 1
            #   u.type = User
            #   if Setting.mail_from.index("@") != nil
            #     u.mail = u.login + Setting.mail_from.to_s[Setting.mail_from.index("@")..Setting.mail_from.size-1]
            #   else
            #     u.mail = u.login + '@example.net'
            #   end
            #   u.first_login = true
            #
            #   if u.save!
            #     wp.assigned_to_id = User.last.id
            #     #добавить юзера в участника проекта
            #     #project_members_path(project_id: @project_for_load, action: 'create')
            #     if Member.where(user_id: User.last.id, project_id: @project_for_load.id).count < 1
            #       @project_for_load.add_member!(u, Role.where(name: "Ответственный за блок мероприятий").first)
            #     end
            #   end
            # else
            #   wp.assigned_to_id = users[0].id
            #   #добавить юзера в участника проекта
            #   #project_members_path(project_id: @project_for_load, action: 'create')
            #   if Member.where(user_id: users[0].id, project_id: @project_for_load.id).count < 1
            #     @project_for_load.add_member!(users[0], Role.where(name: "Ответственный за блок мероприятий").first)
            #   end
            # end

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

            params['assigned_to_id'] = add_user(fio)

            #добавить юзера в участника проекта
            #project_members_path(project_id: @project_for_load, action: 'create')
            if Member.where(user_id: params['assigned_to_id'], project_id: @project_for_load.id).count < 1
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

    settings = PlanUploaderSetting.select('column_type, column_name, column_num, is_pk')
                 .where("setting_type = 'UploadPlanType2'")
                 .order('column_num ASC')
                 .all

    result = ""
    results = []
    result_value = ""
    result_values = []
    point = ""
    points = []

    #row_num = @first_row_num.to_i
    rows = []
    xlsx = Roo::Excelx.new(filename)
    xlsx.each_row_streaming(offset: 1) do |row|
      rr = {}
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

          wp.assigned_to_id = add_user(fio)

          # users = User.find_by_sql("select * from users where lastname||substr(firstname,1,1)||(case when patronymic is null or patronymic = '' then '' else substr(patronymic,1,1) end) = '" + fio[0] + fio[1][0] + fio[2][0] + "'")
          # if users.count == 0
          #   u = User.new(language: Setting.default_language,
          #                mail_notification: Setting.default_notification_option)
          #   u.login = fio[0] + fio[1][0] + fio[2][0]
          #   u.login = convert(u.login.downcase, :english)
          #   u.firstname = fio[1]
          #   u.lastname = fio[0]
          #   if fio[2].present?
          #     u.patronymic = fio[2]
          #   end
          #   u.admin = 0
          #   u.status = 1
          #   #u.language = Setting.default_language
          #   u.type = User
          #   #u.mail_notification = Setting.default_notification_option
          #   if Setting.mail_from.index("@") != nil
          #     u.mail = u.login + Setting.mail_from.to_s[Setting.mail_from.index("@")..Setting.mail_from.size-1]
          #   else
          #     u.mail = u.login + '@example.net'
          #   end
          #   u.first_login = true
          #
          #   if u.save!
          #     wp.assigned_to_id = User.last.id
          #     #добавить юзера в участника проекта
          #     #project_members_path(project_id: @project_for_load, action: 'create')
          #     if Member.where(user_id: User.last.id, project_id: @project_for_load.id).count < 1
          #       @project_for_load.add_member!(u, Role.where(name: "Ответственный за блок мероприятий").first)
          #     end
          #   end
          # else
          #   wp.assigned_to_id = users[0].id
          #   #добавить юзера в участника проекта
          #   #project_members_path(project_id: @project_for_load, action: 'create')
          #   if Member.where(user_id: users[0].id, project_id: @project_for_load.id).count < 1
          #     @project_for_load.add_member!(users[0], Role.where(name: "Ответственный за блок мероприятий").first)
          #   end
          # end
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
          puts "not loaded: " + row['work']
        end
      end
    end

    puts "Insert count: " + insert_count.to_s
    puts "Break count: " + break_count.to_s
  end

  # v2 загрузка плана "Контрольные точки" из электр-го бюджета
  def load_plan2_v2
    prepare_roo
    filename = Rails.root.join('public', @plan_uploader.name.store_path)

    # получаем настройки
    col_num = {}
    settings = PlanUploaderSetting.select('column_type, column_name, column_num, is_pk')
                 .where("setting_type = 'UploadPlanType2'")
                 .order('column_num ASC')
                 .all
    settings.each { |setting| col_num[setting.column_name] = setting.column_num }

    # получаем проект
    @project_for_load = Project.find(params[:project_id])

    result = ""
    result_value = ""
    point = ""

    # поучаем id типа пакета Результат
    if TargetType.find_by(:name => 'Результат', :type => 'TargetType').present?
      target_type_id = TargetType.find_by(:name => 'Результат', :type => 'TargetType').id
    else
      target_type_id = 0
    end


    @target = Target
    @target_value = TargetExecutionValue
    @year = 0
    @quarter = 0
    @reault_values = []
    @kt_id = 0

    insert_tg_count = 0
    insert_kt_count = 0
    insert_count = 0
    break_count = 0
    row_count = 0
    xlsx = Roo::Excelx.new(filename)
    xlsx.each_row_streaming(offset: 1) do |row|
      row_count += 1
      if row[0].value.present? && row[0].value != 0 #Результат

        result = row[0].value
        result = result.sub "Результат :", ""
        result = result.strip
        result = result[0..255]
        result_value = ""
        point = ""

        # ищем или создаем Целевой показатель с типом "Результат"
        @target = Target.where(:project_id => @project_for_load.id,
                              :name => result,
                              :type_id => target_type_id)
                   .first_or_create! do |t|
          t.name = result
          t.type_id = target_type_id
          t.project_id = @project_for_load.id
          t.is_approve = true
          t.parent_id = 0
          insert_tg_count += 1
        end

      else
        if row[1].value.present? && row[1].value != 0 #Значение результата

          result_value = row[1].value
          result_value = result_value.sub "Значение результата :", ""
          result_value = result_value.sub "Значение:", ""
          result_value = result_value.sub "Дата", ""
          result_value = result_value.strip
          result_value = result_value.delete " "
          @result_values = result_value.split(':')
          # выделить значение из строки
          # выделить quarter из строки
          case @result_values[1][3..4]
          when '01', '02', '03'
            @quarter = 1
          when '04', '05', '06'
            @quarter = 2
          when '07', '08', '09'
            @quarter = 3
          when '10', '11', '12'
            @quarter = 4
          end
          # ищем или создаем Значение показателя
          @target_value = TargetExecutionValue.where(:target_id => @target.id,
                                                    :value => @result_values[0].to_i,
                                                    :year => @result_values[1][6..-1].to_i,
                                                    :quarter => @quarter)
                          .first_or_create! do |v|
            v.target_id = @target.id
            v.year = @result_values[1][6..-1]
            v.quarter = @quarter
            v.value = @result_values[0]
          end

        else
          if row[2].present? && row[2].value != 0  #Контрольная точка

            point = row[2].value
            point = point.sub "Контрольная точка :", ""
            point = point.strip
            date_str = point[-11..-2]
            point = point[0..250]
            # создаем пакет работ с типом Контрольная точка
            kt = WorkPackage.new
            #kpoint = WorkPackage.where(:project_id => @project_for_load.id,
            #                       :subject => point,
            #                       :type_id => Type.find_by(name: I18n.t(:default_type_milestone)).id)
            #          .first_or_create! do |kt|
              kt.subject = point
              kt.project_id = @project_for_load.id
              kt.type_id = Type.find_by(name: I18n.t(:default_type_milestone)).id
              kt.status_id = Status.default.id
              kt.plan_type = 'execution'
              kt.author_id = User.current.id
              kt.position = 1
              kt.priority_id = IssuePriority.default.id

              if date_check?(date_str)
                kt.due_date = date_str
              end
            #end
            # сохраняем без валидации
            if kt.save(validate: false)
            #if kpoint.present?

              insert_kt_count += 1
              @kt_id = WorkPackage.last.id
              #@kt_id = kpoint.id

              wpt = WorkPackageTarget.new
              wpt.project_id = @project_for_load.id
              wpt.work_package_id = @kt_id
              wpt.target_id = @target.id
              if @result_values[1][6..-1].to_i != 0
                wpt.year = @result_values[1][6..-1].to_i
              end
              if @quarter != 0
                wpt.quarter = @quarter
              end
              wpt.plan_value = @result_values[0]
              wpt.save

            else
              puts "not loaded: " + row
            end

          else #Мероприятие

            # добавляем дочерние мероприятия
            if row[col_num['subject']].value == "Мероприятия по контрольной точке отсутствуют"
              break_count += 1
              #next
            else
              # task = WorkPackage.where(:project_id => @project_for_load.id,
              #                          :subject => row[col_num['subject']].value.to_s[0..255],
              #                          :start_date => row[col_num['start_date']].value,
              #                          :due_date => row[col_num['due_date']].value
              # )
              #          .first_or_initialize do |wp|

              wp = WorkPackage.new
                #is_new_record = true
                wp.subject = row[col_num['subject']].value.to_s[0..255]
                wp.due_date = row[col_num['due_date']].value
                wp.description = row[col_num['description']].value.to_s[0..255]
                if row[col_num['assigned_to_id']].value == 0
                  wp.assigned_to_id = nil
                end

                if (row[col_num['assigned_to_id']].present?)&&(row[col_num['assigned_to_id']].value != 0)
                  fio = row[col_num['assigned_to_id']].value.delete('.')
                  fio = fio.split(' ')

                  wp.assigned_to_id = add_user(fio)

                  # users = User.find_by_sql("select * from users where lastname||substr(firstname,1,1)||(case when patronymic is null or patronymic = '' then '' else substr(patronymic,1,1) end) = '" + fio[0] + fio[1][0] + fio[2][0] + "'")
                  # if users.count == 0
                  #   u = User.new(language: Setting.default_language,
                  #                mail_notification: Setting.default_notification_option)
                  #   u.login = fio[0] + fio[1][0] + fio[2][0]
                  #   u.login = convert(u.login.downcase, :english)
                  #   u.firstname = fio[1]
                  #   u.lastname = fio[0]
                  #   if fio[2].present?
                  #     u.patronymic = fio[2]
                  #   end
                  #   u.admin = 0
                  #   u.status = 1
                  #   u.type = User
                  #   if Setting.mail_from.index("@") != nil
                  #     u.mail = u.login + Setting.mail_from.to_s[Setting.mail_from.index("@")..Setting.mail_from.size-1]
                  #   else
                  #     u.mail = u.login + '@example.net'
                  #   end
                  #   u.first_login = true
                  #
                  #   if u.save!
                  #     wp.assigned_to_id = User.last.id
                  #     #добавить юзера в участника проекта
                  #     if Member.where(user_id: User.last.id, project_id: @project_for_load.id).count < 1
                  #       @project_for_load.add_member!(u, Role.where(name: "Ответственный за блок мероприятий").first)
                  #     end
                  #   end
                  # else
                  #   wp.assigned_to_id = users[0].id
                  #   #добавить юзера в участника проекта
                  #   if Member.where(user_id: users[0].id, project_id: @project_for_load.id).count < 1
                  #     @project_for_load.add_member!(users[0], Role.where(name: "Ответственный за блок мероприятий").first)
                  #   end
                  # end
                end

                if row[col_num['start_date']].present?
                  if row[col_num['start_date']].value == Date.parse('1899-12-30')
                    wp.start_date = @project_for_load.created_on
                  else
                    wp.start_date  = Date.parse(row[col_num['start_date']].value)
                  end
                else
                  #row['start_date'] = @project_for_load.created_on
                end

                wp.project_id = @project_for_load.id
                wp.type_id = Type.find_by(name: I18n.t(:default_type_task)).id
                wp.status_id = Status.default.id
                wp.plan_type = 'execution'
                wp.author_id = User.current.id
                wp.position = 1
                wp.priority_id = IssuePriority.default.id

                @wp_id = 0
                # сохраняем без валидации
                if wp.save(validate: false)
                  insert_count += 1
                  @wp_id = WorkPackage.last.id
                else
                  puts "not loaded: " + row
                end
              #end

              # добавляем связи иерархии
              # if @kt_id != 0
              #   Relation.find_or_create_by(from_id: @kt_id, to_id: task.id) do |rel|
              #     rel.from_id = @kt_id
              #     rel.to_id = task.id
              #     rel.hierarchy = 1
              #   end
              # end

              if @kt_id != 0 && @wp_id != 0
                Relation.find_or_create_by(from_id: @kt_id, to_id: @wp_id) do |rel|
                  rel.from_id = @kt_id
                  rel.to_id = @wp_id
                  rel.hierarchy = 1
                end
              end

            end
          end
        end
      end
    end

    puts "Row count: " + row_count.to_s
    puts "Insert count: " + insert_count.to_s
    puts "Insert KT count: " + insert_kt_count.to_s
    puts "Insert target count: " + insert_tg_count.to_s
    puts "Break count: " + break_count.to_s
  end

  # загрузка плана из msproject
  def load_msproject
    prepare_roo
    filename = Rails.root.join('public', @plan_uploader.name.store_path)

    settings = PlanUploaderSetting.select('column_name, column_num, is_pk').where("setting_type = 'UploadPlanType6'").order('column_num ASC').all

    row_num = @first_row_num.to_i
    rows = []
    xlsx = Roo::Excelx.new(filename)
    xlsx.each_row_streaming(offset: @first_row_num.to_i - 1) do |row|
      rr = {}
      settings.each { |setting| rr[setting.column_name] = Hash['column_name', setting.column_name, setting.column_name, row[setting.column_num].value, 'is_pk', setting.is_pk] }
      rows.push rr
    end

    #fixed columns
    fc = {}
    fc['id'] = Hash['column_name', 'id', 'id', 0, 'is_pk', 0]
    rows.push fc
    fc['prev_id'] = Hash['column_name', 'prev_id', 'prev_id', 1, 'is_pk', 0]
    rows.push fc
    fc['next_id'] = Hash['column_name', 'next_id', 'next_id', 2, 'is_pk', 0]
    rows.push fc

    puts "Row count: " + rows.count.to_s

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

            fio = params['assigned_to_id'].delete('.')
            fio = fio.split(' ')

            #wp.assigned_to_id = add_user(fio)

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

            params['assigned_to_id'] = add_user(fio)

            #добавить юзера в участника проекта
            #project_members_path(project_id: @project_for_load, action: 'create')
            if Member.where(user_id: params['assigned_to_id'], project_id: @project_for_load.id).count < 1
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

  def add_user(fio)
    assigned_to_id = nil

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
      u.type = User
      if Setting.mail_from.index("@") != nil
        u.mail = u.login + Setting.mail_from.to_s[Setting.mail_from.index("@")..Setting.mail_from.size-1]
      else
        u.mail = u.login + '@example.net'
      end
      u.first_login = true

      if u.save!
        assigned_to_id = User.last.id
        #добавить юзера в участника проекта
        #project_members_path(project_id: @project_for_load, action: 'create')

        add_to_members(assigned_to_id, u)

        # if Member.where(user_id: assigned_to_id, project_id: @project_for_load.id).count < 1
        #   @project_for_load.add_member!(u, Role.where(name: "Ответственный за блок мероприятий").first)
        # end
      end
    else
      assigned_to_id = users[0].id
      #добавить юзера в участника проекта
      #project_members_path(project_id: @project_for_load, action: 'create')

      add_to_members(users[0].id, users[0])

      # if Member.where(user_id: users[0].id, project_id: @project_for_load.id).count < 1
      #   @project_for_load.add_member!(users[0], Role.where(name: "Ответственный за блок мероприятий").first)
      # end
    end

    assigned_to_id
  end

  def add_to_members(user_id, user)
    if Member.where(user_id: user_id, project_id: @project_for_load.id).count < 1
      @project_for_load.add_member!(user, Role.where(name: "Ответственный за блок мероприятий").first)
      add_to_stakeholders(user_id, user)
    end
  end

  def add_to_stakeholders(user_id, user)
    #user = User.find(user_id)
    if user.present?
      su = StakeholderUser.where(user_id: user_id, project_id: @project_for_load.id).first_or_create do |s|
        s.user_id = user_id
        s.organization_id = user.organization_id
        s.name = user.name
        #s.description = added_member.roles.to_s
        s.phone_wrk = user.phone_wrk
        s.phone_wrk_add = user.phone_wrk_add
        s.phone_mobile = user.phone_mobile
        s.mail_add = user.mail_add
        s.address = user.address
        s.cabinet = user.cabinet
      end

      if user.organization_id.present?
        org = Organization.find(user.organization_id)
        if org.present?
          so = StakeholderOrganization.where(organization_id: org.id, project_id: @project_for_load).first_or_create do |s|
            s.organization_id = org.id
            s.name = org.name
            s.phone_wrk = org.phone_wrk
            s.phone_wrk_add = org.phone_wrk_add
            s.phone_mobile = org.phone_mobile
            s.mail_add = org.mail_add
            s.address = org.address
            s.cabinet = org.cabinet
          end
        end
      end
    end
  end

  def get_setting_types
    @settings_types = []
    @plan_uploader_settings_types = PlanUploaderSetting.select(:setting_type).group('setting_type').order('setting_type asc').all
    @plan_uploader_settings_types.each do |setting|
      @settings_types << [t(setting.setting_type), setting.setting_type]
    end
    @settings_types
  end

  def date_check?(date_str)
    begin
      Date.parse(date_str)
      true
    rescue
      false
    end
  end
end
