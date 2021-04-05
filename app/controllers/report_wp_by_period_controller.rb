require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
class ReportWpByPeriodController < ApplicationController
  include Downloadable
  default_search_scope :report_wp_by_period
  before_action :find_optional_project, :verify_reports_wp_by_period_module_active
  def index
  end

  def create
    from = params['filter']['label_by_date_from']
    to = params['filter']['label_by_date_to']
    @selected_wps = @project.work_packages.where(due_date: from..to)
    generate_report
    send_to_user filepath: @report_ready_filepath
  end

  def destroy
    redirect_to action: 'index'
    nil
  end

  protected

  def show_local_breadcrumb
    true
  end

  def generate_report
    template_path = File.absolute_path('.') +'/'+'app/reports/templates/wp_by_period.xlsx'
    @workbook = RubyXL::Parser.parse(template_path)
    @workbook.calc_pr.full_calc_on_load = true
    generate_title_sheet
    generate_main_sheet
    #+tan
    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end
    #-tan

    @report_ready_filepath = dir_path + '/wp_by_period_out.xlsx'
    @workbook.write(@report_ready_filepath)
    exist = false
    current_user.roles_for_project(@project).map do |role|
      exist ||= role.role_permissions.any? {|perm| perm.permission == 'manage_documents'}
    end
    if exist
      pid = spawn('cd ' + File.absolute_path('.') + '/unoconv && unoconv -f pdf ' + @report_ready_filepath)
      @document = @project.documents.build
      @document.category = DocumentCategory.find_by(name: 'Отчет о исполнении мероприятий за период')
      @document.user_id = current_user.id
      @document.title = 'Отчет о исполнении мероприятий за период от ' + DateTime.now.strftime("%d/%m/%Y %H:%M")
      service = AddAttachmentService.new(@document, author: current_user)
      attachment = service.add_attachment_old uploaded_file: File.open(@report_ready_filepath),
                                              filename: 'wp_by_period_out.xlsx'
      @document.attach_files({'0'=> {'id'=> attachment.id}})
      @document.save
    end
  end

  def generate_title_sheet
    sheet = @workbook['Титульный лист']
    sheet[0][0].change_contents(@project.name)
    sheet[22][0].change_contents("за период с " +
                                   params['filter']['label_by_date_from'].split('-').reverse.join('.') +
                                   " по " +
                                   params['filter']['label_by_date_to'].split('-').reverse.join('.'))
  rescue Exception => e
    Rails.logger.info(e.message)
  end

  def generate_main_sheet
    sheet = @workbook['КТ и Мероприятия']
    start_index = 4
    @selected_wps.each_with_index do |wp, i|
      attch = Attachment.where(container_type: 'WorkPackage', container_id: wp.id)
      file_str = ""
      attch.map do |a|
        file_str += a.filename + ", "
      end
      file_str = attch.count > 0 ? file_str.first(-2) : ""
      com_str = ""
      cmmnt = Journal.where(journable_type: 'WorkPackage', journable_id: wp.id)
      cmmnt.map do |c|
        com_str += (c.notes.include?("_Обновлено автоматически") or c.notes == nil or c.notes == "") ? "" : "\n" + c.notes
      end
      sheet.insert_cell(start_index + i, 0, i + 1)
      sheet.insert_cell(start_index + i, 1, wp.status.name)
      sheet.insert_cell(start_index + i, 2, wp.subject)
      sheet.insert_cell(start_index + i, 3, wp.due_date.strftime("%d.%m.%Y"))
      sheet.insert_cell(start_index + i, 4, wp.fact_due_date.nil? ? "" : wp.fact_due_date.strftime("%d.%m.%Y"))
      sheet.insert_cell(start_index + i, 5, wp.assigned_to.nil? ? "" : wp.assigned_to.fio)
      sheet.insert_cell(start_index + i, 6, file_str)
      sheet.insert_cell(start_index + i, 7, com_str)
      for j in 0..7
        cell_format(i, sheet, start_index, j)
      end
    end
  end

  private

  def cell_format(i, sheet, start_index, j)
    sheet[start_index + i][j].change_text_wrap(true)
    sheet[start_index + i][j].
    sheet.sheet_data[start_index + i][0].change_border(:top, 'thin')
    sheet.sheet_data[start_index + i][0].change_border(:left, 'thin')
    sheet.sheet_data[start_index + i][0].change_border(:right, 'thin')
    sheet.sheet_data[start_index + i][0].change_border(:bottom, 'thin')
  end

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def verify_reports_wp_by_period_module_active
    render_403 if @project && !@project.module_enabled?('report_wp_by_period')
  end

end
