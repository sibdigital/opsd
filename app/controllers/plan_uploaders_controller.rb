#-- encoding: UTF-8
#+-tan 2019.04.25
require 'roo'


class PlanUploadersController < ApplicationController

  #include EBHelper

  layout 'admin'

  def index
    @plan_uploaders = PlanUploader.all
  end

  def new
    @plan_uploader = PlanUploader.new
  end

  def create
    @plan_uploader = PlanUploader.new(permitted_params.plan_uploader)

    if @plan_uploader.save
      puts @plan_uploader.name.store_path
      load
      render "new"
      # redirect_to resumes_path, notice: "The resume #{@resume.name} has been uploaded."
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
    filename = Rails.root.join('public',@plan_uploader.name.store_path)
    puts File.file?(filename)
    xlsx = Roo::Excelx.new(filename)
    ebrows = []
    xlsx.each_row_streaming do |row|
      r = EBRow.new row[1].value, row[2].value, row[3].value, row[4].value, row[5].value, row[6].value, row[7].value
      ebrows.push r
    end
    ebrows.each do |erow|
      puts erow.to_s
      if !erow.is_empty?
        wp_name = "#{erow.serial_number} #{erow.name.to_s}"
        wp_list = WorkPackage.where(subject: wp_name).to_a
        if wp_list.size == 0
          wp = WorkPackage.new
          wp.subject = wp_name
          wp.save
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

    attr_accessor :serial_number, :name, :date_begin, :date_end, :employee, :document_charact, :control_level

    @serial_number
    @name
    @date_begin
    @date_end
    @employee
    @document_charact
    @control_level

    def initialize(serial_number, name, date_begin, date_end, employee, document_charact, control_level)
      @serial_number = serial_number
      @name = name
      @date_begin = date_begin
      @date_end = date_end
      @employee = employee
      @document_charact = document_charact
      @control_level = control_level
    end

    def to_s
      "#{@serial_number} #{@name} #{@date_begin} #{@date_end} #{@employee}  #{@control_level}"
    end

    def is_empty?
      (@serial_number == nil || @serial_number == 0  || @serial_number == '') && (@name == nil || @name == 0  || @name == '')
    end
  end

  # private
  # def plan_uploader_params
  #   params.require(:plan_uploader).permit(:name, :attachment, :status, :upload_at)
  # end
end
