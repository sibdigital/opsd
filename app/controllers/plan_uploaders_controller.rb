#-- encoding: UTF-8

#+-tan 2019.04.25

class PlanUploadersController < ApplicationController
  require 'roo'
  require 'date'
  require 'translit'

  RUSSIAN_MONTH_NAMES_SUBSTITUTION = {
    'январь' => 'jan', 'февраль' => 'feb', 'март' => 'mar',
    'апрель' => 'apr', 'май' => 'may', 'июнь' => 'jun',
    'июль' => 'jul', 'август' => 'aug', 'сентябрь' => 'sep',
    'октябрь' => 'oct', 'ноябрь' => 'nov', 'декабрь' => 'dec'
  }.freeze

  def index
    @plan_uploaders = PlanUploader.all
  end

  def new
    @project = Project.find(params[:project_id])
    @plan_uploader = PlanUploader.new
  end

  def create
    @plan_uploader = PlanUploader.new(permitted_params.plan_uploader)
    @first_row_num = params[:first_row_num]

    if @plan_uploader.save
      # puts @plan_uploader.name.store_path
      # if @plan_uploader.status
      # load_eb
      # else
      load
      # end
      # render "new"
      redirect_to project_stages_path, notice: "Данные загружены."
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

    settings = PlanUploaderSetting.select('column_name, column_num, is_pk').where("table_name = 'work_packages'").order('column_num ASC').all

    rows = []
    xlsx = Roo::Excelx.new(filename)
    xlsx.each_row_streaming(offset: @first_row_num.to_i - 1) do |row|
      rr = {}
      settings.each { |setting| rr[setting.column_name] = Hash['column_name', setting.column_name, setting.column_name, row[setting.column_num].value] }
      rows.push rr
    end

    @project_for_load = Project.find(params[:project_id])

    rows.each do |row|
      if row.present?
        wp_name = (row['subject']['subject']).to_s
        #wp_list = WorkPackage.where(subject: wp_name).to_a
        wp_list = WorkPackage.find_or_create_by(subject: wp_name) do |wp|
        if wp_list.empty?
          # если такой задачи нет
          #wp = WorkPackage.find_or_initialize_by do |task|
          wp = WorkPackage.new
          params = {}
          row.to_h.each do |r|
            params[r[0]] = r[1][r[0]]
          end

          if params['assigned_to_id'] == 0
            params['assigned_to_id'] = nil
          end

          if (params['assigned_to_id'].present?)&&(params['assigned_to_id'] != 0)
            fio = params['assigned_to_id'].split(' ')
            user = User.find_or_create_by(firstname: fio[1], lastname: fio[0], patronymic: fio[2]) do |u|
              u.login = fio[0] + fio[1][0] + fio[2][0]
              u.login = Translit.convert(u.login.downcase, :english)
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

            #include project member
            #
            #project_members_path(project_id: @project_for_load, )
            #

            # member = {}
            # member['user_id'] = user.id
            # member['role_id'] = Role.where(name: "Участник").first.id
            # members[user.id] = new_member(user_id)
            # @project_for_load.members << member

            # @member = Member.new
            # member_params = {}
            # member_params['user_id'] = user.id
            # member_params['project_id'] = @project_for_load.id
            # member_params['mail_notification'] = false
            #
            # member_roles_params = {}
            # member_roles_params['role_id'] = Role.where(name: "Участник").first.id
            # @member.attributes = member_params
            # #@member.member_roles.attributes = member_roles_params
            # @member.save
            # #@member.member_roles.new(role_id: Role.where(name: "Участник").first.id)

            params['assigned_to_id'] = user.id
          end

          if params['control_level_id'].present?
            # find control_level

          end

          if params['start_date'].present?
            if params['start_date'] == Date.parse('1899-12-30')
              params['start_date'] = @project_for_load.created_on
            end
          end

          params['project_id'] = @project_for_load.id
          params['type_id'] = Type.find_by(name: I18n.t(:default_type_task)).id
          params['status_id'] = Status.default.id # find_by(name: I18n.t(:default_status_new))
          params['plan_type'] = 'execution'
          params['author_id'] = User.current.id
          params['position'] = 1
          params['priority_id'] = IssuePriority.default.id

          wp.attributes = params
          wp.save!

          # ищем id родителя
          parent_id = nil
          plan_num_pp = params['plan_num_pp'].to_s
          if !plan_num_pp.rindex(".").nil?
            plan_num_pp = plan_num_pp[0..plan_num_pp.rindex(".")]
            plan_num_pp = plan_num_pp[0..plan_num_pp.size-2]
            parent_id = WorkPackage.where(project_id: @project_for_load.id, plan_num_pp: plan_num_pp).first.id

            # добавляем связи иерархии
            if parent_id.present?
              p = {}
              p['from_id'] = parent_id
              p['to_id'] = wp.id
              p['hierarchy'] = 1
              re = Relation.new
              re.attributes = p
              re.save!
            end
          end

        else
          # обновить запись
          # добавить запись в w_p_journals

        end
      end
    end

    #
    #     ebrows.each do |erow|
    #       if erow.wp_id != nil
    #         if erow.control_level != nil
    #           params = {}
    #           params['from_id'] = ebrows[erow.control_level.to_i - 1].wp_id
    #           params['to_id'] = erow.wp_id
    #           params['hierarchy'] = 1
    #           #puts params
    #           if params['from_id'] != params['to_id']
    #             re = Relation.new
    #             re.attributes = params
    #             re.save!
    #           end
    #         end
    #       end
    #     end
  end

  #   def load
  #     prepare_roo
  #     filename = Rails.root.join('public', @plan_uploader.name.store_path)
  #     #puts File.file?(filename)
  #     xlsx = Roo::Excelx.new(filename)
  #     ebrows = []
  #     xlsx.each_row_streaming(offset: 1) do |row|
  #       r = EBRow.new row[0].value, row[3].value, russian_to_english_date(row[5].value), russian_to_english_date(row[6].value), nil, row[2].value, row[7].value
  #       ebrows.push r
  #     end
  #
  #     #@project_for_load = Project.find_by(identifier: params[:project_id])
  #     @project_for_load = Project.find(params[:project_id])
  #
  #     ebrows.each do |erow|
  #       #puts erow.to_s
  #       if !erow.is_empty?
  #         #wp_name = "#{erow.serial_number} #{erow.name.to_s}"
  #         wp_name = "#{erow.name.to_s}"
  #         wp_list = WorkPackage.where(subject: wp_name).to_a
  #         if wp_list.size == 0
  #           wp = WorkPackage.new
  #           params = {}
  #           params['subject'] = wp_name[0, 250]
  #           params['description'] = wp_name
  #           params['project_id'] = @project_for_load.id
  #           params['start_date'] = DateTime.parse(erow.date_begin)
  #           params['due_date'] = DateTime.parse(erow.date_end)
  #           params['type_id'] = Type.find_by(name: I18n.t(:default_type_task)).id
  #           params['status_id'] = Status.default.id # find_by(name: I18n.t(:default_status_new))
  #           params['plan_type'] = 'execution'
  #           params['author_id'] = User.current.id
  #           params['position'] = 1
  #           params['priority_id'] = IssuePriority.default.id
  #           #params['assigned_to'] = 1
  #           wp.attributes = params
  #           wp.save!
  #
  #           erow.wp_id = WorkPackage.last.id
  #         else
  #
  #         end
  #       end
  #     end
  #
  #     ebrows.each do |erow|
  #       if erow.wp_id != nil
  #         if erow.control_level != nil
  #           params = {}
  #           params['from_id'] = ebrows[erow.control_level.to_i - 1].wp_id
  #           params['to_id'] = erow.wp_id
  #           params['hierarchy'] = 1
  #           #puts params
  #           if params['from_id'] != params['to_id']
  #             re = Relation.new
  #             re.attributes = params
  #             re.save!
  #           end
  #         end
  #       end
  #     end
  #   end
  #
  #   def load_eb
  #     prepare_roo
  #     filename = Rails.root.join('public',@plan_uploader.name.store_path)
  #     #puts File.file?(filename)
  #     xlsx = Roo::Excelx.new(filename)
  #     ebrows = []
  #     xlsx.each_row_streaming do |row|
  #       r = EBRow.new row[1].value, row[2].value, row[3].value, row[4].value, row[5].value, row[6].value, row[7].value
  #       ebrows.push r
  #     end
  #
  #     @project_for_load = Project.find_by(identifier: params[:project_id])
  #
  #     ebrows.each do |erow|
  #       #puts erow.to_s
  #       if !erow.is_empty?
  #         wp_name = "#{erow.serial_number} #{erow.name.to_s}"
  #         wp_list = WorkPackage.where(subject: wp_name).to_a
  #         if wp_list.size == 0
  #           wp = WorkPackage.new
  #           params = {}
  #           params['subject'] = wp_name[0,250]
  #           params['description'] = wp_name
  #           params['project_id'] = @project_for_load.id
  #           params['type_id'] = Type.find_by(name: I18n.t(:default_type_task)).id
  #           params['status_id'] = Status.default.id# find_by(name: I18n.t(:default_status_new))
  #           params['plan_type'] = 'execution'
  #           params['author_id'] = User.current.id
  #           params['position'] = 1
  #           params['priority_id'] = IssuePriority.default.id
  #           params['due_date'] = erow.date_end
  #           #params['assigned_to'] = 1
  #           wp.attributes = params
  #           wp.save!
  #         else
  #
  #         end
  #       end
  #     end
  #   end

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

  class EBRow
    attr_accessor :serial_number, :name, :date_begin, :date_end, :employee, :document_charact, :control_level, :wp_id

    @serial_number
    @name
    @date_begin
    @date_end
    @employee
    @document_charact
    @control_level
    @wp_id

    def initialize(serial_number, name, date_begin, date_end, employee, document_charact, control_level)
      @serial_number = serial_number
      @name = name
      @date_begin = date_begin
      @date_end = date_end
      @employee = employee
      @document_charact = document_charact
      @control_level = control_level
      @wp_id = nil
    end

    def to_s
      "#{@serial_number} #{@name} #{@date_begin} #{@date_end} #{@employee}  #{@control_level}"
    end

    def is_empty?
      (@serial_number == nil || @serial_number == 0 || @serial_number == '') && (@name == nil || @name == 0 || @name == '')
    end
  end

  private

  # def plan_uploader_params
  #   params.require(:plan_uploader).permit(:name, :attachment, :status, :upload_at)
  # end

  def russian_to_english_date(date_string)
    date_string.downcase.gsub(/январь|февраль|март|апрель|май|июнь|июль|август|сентябрь|октябрь|ноябрь|декабрь/, RUSSIAN_MONTH_NAMES_SUBSTITUTION)
  end

  def new_member(user_id)
    Member.new(permitted_params.member).tap do |member|
      member.user_id = user_id if user_id
    end
  end

end
