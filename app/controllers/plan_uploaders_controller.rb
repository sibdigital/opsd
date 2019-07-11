#-- encoding: UTF-8
#+-tan 2019.04.25
require 'roo'


class PlanUploadersController < ApplicationController

  #include EBHelper
  require 'date'

  RUSSIAN_MONTH_NAMES_SUBSTITUTION = { 'январь' => 'jan', 'февраль' => 'feb', 'март' => 'mar',
                                       'апрель' => 'apr', 'май' => 'may', 'июнь' => 'jun',
                                       'июль' => 'jul', 'август' => 'aug', 'сентябрь' => 'sep',
                                       'октябрь' => 'oct', 'ноябрь' => 'nov', 'декабрь' => 'dec'}

  def index
    @plan_uploaders = PlanUploader.all
  end

  def new
    @project = Project.find(params[:project_id])
    @plan_uploader = PlanUploader.new
  end

  def create
    @plan_uploader = PlanUploader.new(permitted_params.plan_uploader)

    if @plan_uploader.save
      puts @plan_uploader.name.store_path
      if @plan_uploader.status
        load_eb
      else
        load
      end
      #render "new"
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

  def load
    prepare_roo
    filename = Rails.root.join('public', @plan_uploader.name.store_path)
    puts File.file?(filename)
    xlsx = Roo::Excelx.new(filename)
    ebrows = []
    xlsx.each_row_streaming(offset: 1) do |row|
      r = EBRow.new row[0].value, row[3].value, russian_to_english_date(row[5].value), russian_to_english_date(row[6].value), nil, row[2].value, row[7].value
      ebrows.push r
    end

    #@project_for_load = Project.find_by(identifier: params[:project_id])
    @project_for_load = Project.find(params[:project_id])

    ebrows.each do |erow|
      puts erow.to_s
      if !erow.is_empty?
        #wp_name = "#{erow.serial_number} #{erow.name.to_s}"
        wp_name = "#{erow.name.to_s}"
        wp_list = WorkPackage.where(subject: wp_name).to_a
        if wp_list.size == 0
          wp = WorkPackage.new
          params = {}
          params['subject'] = wp_name[0, 250]
          params['description'] = wp_name
          params['project_id'] = @project_for_load.id
          params['start_date'] = DateTime.parse(erow.date_begin)
          params['due_date'] = DateTime.parse(erow.date_end)
          params['type_id'] = Type.find_by(name: I18n.t(:default_type_task)).id
          params['status_id'] = Status.default.id # find_by(name: I18n.t(:default_status_new))
          params['plan_type'] = 'execution'
          params['author_id'] = User.current.id
          params['position'] = 1
          params['priority_id'] = IssuePriority.default.id
          #params['assigned_to'] = 1
          wp.attributes = params
          wp.save!

          erow.wp_id = WorkPackage.last.id
        else

        end
      end
    end

    ebrows.each do |erow|
      if erow.wp_id != nil
        if erow.control_level != nil
          params = {}
          params['from_id'] = ebrows[erow.control_level.to_i - 1].wp_id
          params['to_id'] = erow.wp_id
          params['hierarchy'] = 1
          print params
          if params['from_id'] != params['to_id']
            re = Relation.new
            re.attributes = params
            re.save!
          end
        end
      end
    end
  end

  def load_eb
    prepare_roo
    filename = Rails.root.join('public',@plan_uploader.name.store_path)
    puts File.file?(filename)
    xlsx = Roo::Excelx.new(filename)
    ebrows = []
    xlsx.each_row_streaming do |row|
      r = EBRow.new row[1].value, row[2].value, row[3].value, row[4].value, row[5].value, row[6].value, row[7].value
      ebrows.push r
    end

    @project_for_load = Project.find_by(identifier: params[:project_id])

    ebrows.each do |erow|
      puts erow.to_s
      if !erow.is_empty?
        wp_name = "#{erow.serial_number} #{erow.name.to_s}"
        wp_list = WorkPackage.where(subject: wp_name).to_a
        if wp_list.size == 0
          wp = WorkPackage.new
          params = {}
          params['subject'] = wp_name[0,250]
          params['description'] = wp_name
          params['project_id'] = @project_for_load.id
          params['type_id'] = Type.find_by(name: I18n.t(:default_type_task)).id
          params['status_id'] = Status.default.id# find_by(name: I18n.t(:default_status_new))
          params['plan_type'] = 'execution'
          params['author_id'] = User.current.id
          params['position'] = 1
          params['priority_id'] = IssuePriority.default.id
          params['due_date'] = erow.date_end
          #params['assigned_to'] = 1
          wp.attributes = params
          wp.save!
        else

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
          (number.include?('.') || (/\A[-+]?\d+E[-+]?\d+\z/i =~ number)) ? Float(number) : number.to_s.to_i
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
      (@serial_number == nil || @serial_number == 0  || @serial_number == '') && (@name == nil || @name == 0  || @name == '')
    end

  end

  private
  # def plan_uploader_params
  #   params.require(:plan_uploader).permit(:name, :attachment, :status, :upload_at)
  # end

  def russian_to_english_date(date_string)
    date_string.downcase.gsub(/январь|февраль|март|апрель|май|июнь|июль|август|сентябрь|октябрь|ноябрь|декабрь/, RUSSIAN_MONTH_NAMES_SUBSTITUTION)
  end

end
