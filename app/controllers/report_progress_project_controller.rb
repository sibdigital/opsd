require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
class ReportProgressProjectController < ApplicationController

  include Downloadable

  default_search_scope :report_progress_project

  before_action :find_optional_project, :verify_reportsProgressProject_module_activated


  def index
    @selected_target_id = 0
    @project = Project.find(params[:project_id])
    if @project.national_project_id
      @national_project = NationalProject.find(@project.national_project_id)
    else
      @national_project = nil
    end
    if @project.federal_project_id
      @federal_project = NationalProject.find(@project.federal_project_id)
    else
      @federal_project = nil
    end

    if  params[:report_id] == 'report_progress_project'
      generate_project_progress_report_out
      send_to_user filepath: @ready_project_progress_report_path
      # generate_report_progress_project_pril_1_2_out
    end

    if  params[:report_id] == 'report_progress_project_pril_1_2'
      #index_params
      generate_report_progress_project_pril_1_2_out
      send_to_user filepath: @ready_report_progress_project_pril_1_2_path
    end


    id_type_indicator = Enumeration.find_by(name: I18n.t(:default_indicator)).id
    @targets = Target.where(project_id: @project.id, type_id: id_type_indicator)

#    @targets = @project.targets
    @target = @targets.first
  end

  def generate_project_progress_report_out
    template_path = File.absolute_path('.') +'/'+'app/reports/templates/project_progress_report.xlsx'
    @workbook = RubyXL::Parser.parse(template_path)
    @workbook.calc_pr.full_calc_on_load = true

    generate_title_sheet
    generate_key_risk_sheet
    generate_targets_sheet
    generate_status_execution_budgets_sheet
    generate_budgets_execution_details_sheet
    generate_status_achievement_sheet
    generate_dynamic_achievement_kt_sheet
    generate_info_achievement_rktm_sheet

    #+tan
    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end
    #-tan

    @ready_project_progress_report_path = dir_path + '/project_progress_report_out.xlsx'
    @workbook.write(@ready_project_progress_report_path)
    #bbm(
    exist = false
    current_user.roles_for_project(@project).map do |role|
      exist ||= role.role_permissions.any? {|perm| perm.permission == 'manage_documents'}
    end
    if exist
      pid = spawn('cd ' + File.absolute_path('.') + '/unoconv && unoconv -f pdf ' + @ready_project_progress_report_path)
      @document = @project.documents.build
      @document.category = DocumentCategory.find_by(name: 'Отчет о ходе реализации проекта')
      @document.user_id = current_user.id
      @document.title = 'отчет о ходе реализации проекта от ' + DateTime.now.strftime("%d/%m/%Y %H:%M")
      service = AddAttachmentService.new(@document, author: current_user)
      attachment = service.add_attachment_old uploaded_file: File.open(@ready_project_progress_report_path),
                                 filename: 'project_progress_report_out.xlsx'
      @document.attach_files({'0'=> {'id'=> attachment.id}})
      @document.save
    end
    # )
  end

  def generate svod_otchet

  end

  def generate_report_progress_project_pril_1_2_out
    @project = Project.find(params[:project_id])
    template_path = File.absolute_path('.') +'/'+'app/reports/templates/report_progress_project_pril_1_2.xlsx'
    @workbook_pril = RubyXL::Parser.parse(template_path)
    @workbook_pril.calc_pr.full_calc_on_load = true

    generate_pril_1_2

    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end

    @ready_report_progress_project_pril_1_2_path = dir_path + '/report_progress_project_pril_1_2_out.xlsx'
    @workbook_pril.write(@ready_report_progress_project_pril_1_2_path)
    # send_to_user filepath: @ready_report_progress_project_pril_1_2_path
#    send_file @ready_report_progress_project_pril_1_2_path,  :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :disposition => 'attachment'
#     send_data @workbook_pril.stream.string, filename: "report_progress_project_pril_1_2_out.xlsx",
#              disposition: 'attachment'
  rescue Exception => e
    Rails.logger.info(e.message)
  end


  def generate_pril_1_2
    #puts @target.id
    #puts params[:target_id]
    sheet = @workbook_pril['Данные для диаграмм']
    selected_target = params[:target]

    target_id = params[:selected_target_id] == nil ? 0 : params[:selected_target_id]
    values = get_target_graph_values(target_id.to_s)

    sheet[2][3].raw_value = values["target_quarter1_value"] == nil ? 0 : values["target_quarter1_value"].to_f
    sheet[2][4].raw_value = values["target_quarter1_value"] == nil ? 0 : values["target_quarter1_value"].to_f
    sheet[2][5].raw_value = values["fact_quarter1_value"] == nil ? 0 : values["fact_quarter1_value"].to_f

    sheet[3][2].raw_value = values["basic_value"] == nil ? 0 : values["basic_value"].to_f
    sheet[3][3].raw_value = values["target_quarter2_value"] == nil ? 0 : values["target_quarter2_value"].to_f
    sheet[3][4].raw_value = values["target_quarter2_value"] == nil ? 0 : values["target_quarter2_value"].to_f

    sheet[3][5].raw_value = values["fact_quarter2_value"] == nil ? 0 : values["fact_quarter2_value"].to_f

    sheet[4][2].raw_value = values["basic_value"]== nil ? 0 : values["basic_value"].to_f
    sheet[4][3].raw_value = values["target_quarter3_value"] == nil ? 0 : values["target_quarter3_value"].to_f
    sheet[4][4].raw_value = values["target_quarter3_value"] == nil ? 0 : values["target_quarter3_value"].to_f
    sheet[4][5].raw_value = values["fact_quarter3_value"] == nil ? 0 : values["fact_quarter3_value"].to_f

    sheet[5][2].raw_value = values["basic_value"]== nil ? 0 : values["basic_value"].to_f
    sheet[5][3].raw_value = values["target_quarter4_value"] == nil ? 0 : values["target_quarter4_value"].to_f
    sheet[5][4].raw_value = values["target_quarter4_value"] == nil ? 0 : values["target_quarter4_value"].to_f
    sheet[5][5].raw_value = values["fact_quarter4_value"] == nil ? 0 : values["fact_quarter4_value"].to_f

    sheet = @workbook_pril['Приложение 1']
    sheet[1][3].change_contents("График достижения показателя: ")
    sheet.insert_cell(2,3, values["name"])

    sheet = @workbook_pril['Приложение 2']
    sheet[1][3].change_contents("График достижения показателя: ")
    sheet.insert_cell(2,3, values["name"])
  rescue Exception => e
    Rails.logger.info(e.message)
  end

  def generate_title_sheet

    @leader_federal_project = @federal_project == nil ? "" : (@federal_project.leader == nil ? "" : @federal_project.leader)
    @date_today = Date.today.strftime("%d.%m.%Y")

    sheet = @workbook['Титульный лист']

    sheet[9][3].change_contents(@leader_federal_project)
    sheet[12][3].change_contents(@date_today)
    sheet[22][11].change_contents(@project.name)
  rescue Exception => e
    Rails.logger.info(e.message)
  end

  def generate_key_risk_sheet
       sheet = @workbook['Ключевые риски']
       workPackageProblems = WorkPackageProblem.where(project_id: @project.id)

       data_row = 3
       workPackageProblems.each_with_index do |workPackageProblem, i|
       status_risk = 0
       if workPackageProblem.risk!=nil
         status_risk = get_v_risk_problem_stat(workPackageProblem.risk.id.to_s)
       end

       sheet.insert_cell(data_row + i, 0, i+1)
       sheet.insert_cell(data_row + i, 1, "")

       if status_risk == 1
         sheet.sheet_data[data_row + i][1].change_fill('0ba53d')
       elsif status_risk == 2
         sheet.sheet_data[data_row + i][1].change_fill('ffd800')
       elsif status_risk == 3
         sheet.sheet_data[data_row + i][1].change_fill('ff0000')
       else
           sheet.sheet_data[data_row + i][1].change_fill('d7d7d7')
       end
       sheet.insert_cell(data_row + i, 2, workPackageProblem.work_package.subject)
       sheet.insert_cell(data_row + i, 3, workPackageProblem.risk==nil ? "" : workPackageProblem.risk.description)
       sheet.insert_cell(data_row + i, 4, workPackageProblem.description)

       sheet.sheet_data[data_row + i][0].change_border(:top, 'thin')
       sheet.sheet_data[data_row + i][0].change_border(:bottom, 'thin')
       sheet.sheet_data[data_row + i][0].change_border(:left, 'thin')
       sheet.sheet_data[data_row + i][0].change_border(:right, 'thin')

       sheet.sheet_data[data_row + i][1].change_border(:top, 'thin')
       sheet.sheet_data[data_row + i][1].change_border(:bottom, 'thin')
       sheet.sheet_data[data_row + i][1].change_border(:left, 'thin')
       sheet.sheet_data[data_row + i][1].change_border(:right, 'thin')

       sheet.sheet_data[data_row + i][2].change_border(:top, 'thin')
       sheet.sheet_data[data_row + i][2].change_border(:bottom, 'thin')
       sheet.sheet_data[data_row + i][2].change_border(:left, 'thin')
       sheet.sheet_data[data_row + i][2].change_border(:right, 'thin')

       sheet.sheet_data[data_row + i][3].change_border(:top, 'thin')
       sheet.sheet_data[data_row + i][3].change_border(:bottom, 'thin')
       sheet.sheet_data[data_row + i][3].change_border(:left, 'thin')
       sheet.sheet_data[data_row + i][3].change_border(:right, 'thin')

       sheet.sheet_data[data_row + i][4].change_border(:top, 'thin')
       sheet.sheet_data[data_row + i][4].change_border(:bottom, 'thin')
       sheet.sheet_data[data_row + i][4].change_border(:left, 'thin')
       sheet.sheet_data[data_row + i][4].change_border(:right, 'thin')

       end

    #  0ba53d -зеленый
    #  ff0000 -красный
    #  ffd800 -желтый
    #  d7d7d7 - серый

    # установка цвета статуса для риска
    sheet = @workbook['Титульный лист']
    if get_v_risk_problem_stat_critic == 1
      sheet.sheet_data[27][5].change_fill('ff0000')
    elsif get_v_risk_problem_stat_low == 1
      sheet.sheet_data[27][5].change_fill('ffd800')
    else
      sheet.sheet_data[27][5].change_fill('d7d7d7')
    end

    if get_v_risk_problem_stat_solved == 1
      sheet.sheet_data[27][5].change_fill('0ba53d')
    end
  rescue Exception => e
    Rails.logger.info(e.message)
  end

  def generate_targets_sheet

    sheet = @workbook['Сведения о значениях целей']
    result_array_targets = get_value_targets_indicators
    status = 0
    data_row = 4
    result_array_targets.each_with_index do |target, i|
    factQuarterTargetValue = target["fact_quarter4_value"] != "0" ? target["fact_quarter4_value"] : ( target["fact_quarter3_value"]!= "0" ? target["fact_quarter3_value"] : (target["fact_quarter2_value"] != "0" ? target["fact_quarter2_value"] : (target["fact_quarter1_value"] != "0" ? target["fact_quarter1_value"] : "0")) )
    procent = '%.2f' %(target["plan_year_value"].to_i == 0 ? 0 : (factQuarterTargetValue.to_f / target["plan_year_value"].to_f )*100)
    measure_unit = target["measure_name"] == nil ? "" : target["measure_name"].to_s
    devation = procent.to_f / 100
    no_devation =  Setting.find_by(name: 'no_devation').value
    small_devation =  Setting.find_by(name: 'small_devation').value

    sheet.insert_cell(data_row + i, 0, i+1)
    sheet.insert_cell(data_row + i, 1, "")
    if devation < small_devation.to_f
      sheet.sheet_data[data_row + i][1].change_fill('ff0000')
      status = 1
    elsif (devation >= small_devation.to_f && devation >  no_devation.to_f)
      sheet.sheet_data[data_row + i][1].change_fill('ffd800')
      if status != 1
        status = 2
      end
    elsif devation  == no_devation.to_f
        sheet.sheet_data[data_row + i][1].change_fill('0ba53d')
        if status != 1 && status != 2
          status = 3
        end
    else
      sheet.sheet_data[data_row + i][1].change_fill('d7d7d7')
    end

      sheet.insert_cell(data_row + i, 2, target["name"])
      sheet.insert_cell(data_row + i, 3, measure_unit)
      sheet.insert_cell(data_row + i, 4, target["fact_year_value"].to_f)
      sheet.insert_cell(data_row + i, 5, target["fact_quarter1_value"].to_f)
      sheet.insert_cell(data_row + i, 6, target["fact_quarter2_value"].to_f)
      sheet.insert_cell(data_row + i, 7, target["fact_quarter3_value"].to_f)
      sheet.insert_cell(data_row + i, 8, target["fact_quarter4_value"].to_f)
      sheet.insert_cell(data_row + i, 9, target["plan_year_value"].to_f)
      sheet.insert_cell(data_row + i, 10, procent)
      sheet.insert_cell(data_row + i, 11, "")

      sheet.sheet_data[data_row + i][0].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][0].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][0].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][0].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][1].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][1].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][1].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][1].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][2].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][2].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][2].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][2].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][3].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][3].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][3].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][3].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][4].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][4].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][4].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][4].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][5].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][5].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][5].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][5].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][6].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][6].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][6].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][6].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][7].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][7].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][7].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][7].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][8].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][8].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][8].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][8].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][9].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][9].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][9].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][9].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][10].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][10].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][10].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][10].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i][11].change_border(:top, 'thin')
      sheet.sheet_data[data_row + i][11].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i][11].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i][11].change_border(:right, 'thin')

    end

    #  0ba53d -зеленый
    #  ff0000 -красный
    #  ffd800 -желтый
    #  d7d7d7 - серый

    # установка цвета статуса для показателей на титульном листе
    sheet = @workbook['Титульный лист']
    if status == 1
       sheet.sheet_data[27][9].change_fill('ff0000')
    elsif status == 2
      sheet.sheet_data[27][9].change_fill('ffd800')
    elsif status == 3
      sheet.sheet_data[27][9].change_fill('0ba53d')
    else
      sheet.sheet_data[27][9].change_fill('d7d7d7')
    end
  rescue Exception => e
    Rails.logger.info(e.message)
  end


  def generate_budgets_execution_details_sheet
    sheet = @workbook['Сведения об исполнении бюджета']

    no_devation =  Setting.find_by(name: 'no_devation').value
    small_devation =  Setting.find_by(name: 'small_devation').value

    budget_array = get_budjet_by_cost_type


    sheet.insert_cell(5, 0," 1.")
    cell = sheet[5][0]
    cell.change_text_wrap(true)
    sheet.sheet_data[5][0].change_horizontal_alignment('center')
    sheet.sheet_data[5][0].change_vertical_alignment('center')

    sheet.sheet_data[5][0].change_border(:top, 'thin')
    sheet.sheet_data[5][0].change_border(:left, 'thin')
    sheet.sheet_data[5][0].change_border(:right, 'thin')
    sheet.sheet_data[5][0].change_border(:bottom, 'thin')

    sheet.insert_cell(5, 1,"")
    sheet.sheet_data[5][1].change_border(:top, 'thin')
    sheet.sheet_data[5][1].change_border(:left, 'thin')
    sheet.sheet_data[5][1].change_border(:right, 'thin')
    sheet.sheet_data[5][1].change_border(:bottom, 'thin')


    sheet.insert_cell(5, 2, "")
    if budget_array.count > 0
      sheet[5][2].change_contents(budget_array[0]["national_project_goal"])

      cell = sheet[5][2]
      cell.change_text_wrap(true)
      sheet.sheet_data[5][2].change_horizontal_alignment('center')
      sheet.sheet_data[5][2].change_vertical_alignment('center')
    end
    sheet.sheet_data[5][2].change_border(:top, 'thin')
    sheet.sheet_data[5][2].change_border(:left, 'thin')
    sheet.sheet_data[5][2].change_border(:right, 'thin')
    sheet.sheet_data[5][2].change_border(:bottom, 'thin')

    sheet.insert_cell(5, 3, "")
    sheet.insert_cell(5, 4, "")
    sheet.insert_cell(5, 5, "")
    sheet.insert_cell(5, 6, "")
    sheet.insert_cell(5, 7, "")
    sheet.insert_cell(5, 8, "")
    sheet.insert_cell(5, 9, "")

    sheet.sheet_data[5][3].change_border(:top, 'thin')
    sheet.sheet_data[5][3].change_border(:left, 'thin')
    sheet.sheet_data[5][3].change_border(:right, 'thin')
    sheet.sheet_data[5][3].change_border(:bottom, 'thin')

    sheet.sheet_data[5][4].change_border(:top, 'thin')
    sheet.sheet_data[5][4].change_border(:left, 'thin')
    sheet.sheet_data[5][4].change_border(:right, 'thin')
    sheet.sheet_data[5][4].change_border(:bottom, 'thin')

    sheet.sheet_data[5][5].change_border(:top, 'thin')
    sheet.sheet_data[5][5].change_border(:left, 'thin')
    sheet.sheet_data[5][5].change_border(:right, 'thin')
    sheet.sheet_data[5][5].change_border(:bottom, 'thin')

    sheet.sheet_data[5][6].change_border(:top, 'thin')
    sheet.sheet_data[5][6].change_border(:left, 'thin')
    sheet.sheet_data[5][6].change_border(:right, 'thin')
    sheet.sheet_data[5][6].change_border(:bottom, 'thin')

    sheet.sheet_data[5][7].change_border(:top, 'thin')
    sheet.sheet_data[5][7].change_border(:left, 'thin')
    sheet.sheet_data[5][7].change_border(:right, 'thin')
    sheet.sheet_data[5][7].change_border(:bottom, 'thin')

    sheet.sheet_data[5][8].change_border(:top, 'thin')
    sheet.sheet_data[5][8].change_border(:left, 'thin')
    sheet.sheet_data[5][8].change_border(:right, 'thin')
    sheet.sheet_data[5][8].change_border(:bottom, 'thin')

    sheet.sheet_data[5][9].change_border(:top, 'thin')
    sheet.sheet_data[5][9].change_border(:left, 'thin')
    sheet.sheet_data[5][9].change_border(:right, 'thin')
    sheet.sheet_data[5][9].change_border(:bottom, 'thin')

    sheet.merge_cells(5, 2, 5, 9)

    id_type_result = Enumeration.find_by(name: I18n.t(:default_result)).id
    targets = Target.where(project_id: @project.id, type_id: id_type_result, is_approve: true)

    cost_types = CostType.all
    id_target = 0
    count_target= 0
    m = 0
    start_index = 7
    array = Array.new(cost_types.count) {Array.new (6)}
    targets.each_with_index do |target, i|
      if id_target != target["id"].to_i
        count_target += 1
      end
      count_cost_type = 1
      mapSumTarget = {}
      mapCostTypeTarget = {}
      cost_types.each_with_index do |cost_type, j|
        punkt = "1." + count_target.to_s + "." + count_cost_type.to_s + "."

        sheet.insert_cell(start_index+j+m, 0, punkt)
        sheet.sheet_data[start_index+j+m][0].change_horizontal_alignment('center')
        sheet.sheet_data[start_index+j+m][0].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][0].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][0].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][0].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][0].change_border(:bottom, 'thin')

        sheet.insert_cell(start_index+j+m, 1, "")
#        sheet.sheet_data[start_index+j+m][1].change_fill('d7d7d7')

        sheet.sheet_data[start_index+j+m][1].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][1].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][1].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][1].change_border(:bottom, 'thin')

        sheet.insert_cell(start_index+j+m, 2, cost_type.name)

        sheet.sheet_data[start_index+j+m][2].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][2].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][2].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][2].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][2].change_border(:bottom, 'thin')
        cell = sheet[start_index+j+m][2]
        cell.change_text_wrap(true)


        value_passport_units = 0
        value_consolidate_units = 0
        value_limit_units = 0
        value_recorded_liability = 0
        value_kassa = 0
        value_procent = 0
        value_devation = 0
        budget_array.each_with_index do |budget, l|
        if  (budget["cost_type_id"].to_i == cost_type.id) &&
            (budget["id"].to_i == target.id)
            value_passport_units = budget["passport_units"] == nil  ? 0 : budget["passport_units"]
            value_consolidate_units = budget["consolidate_units"] == nil  ? 0 : budget["consolidate_units"]
            value_limit_units = budget["limit_units"] == nil  ? 0 : budget["limit_units"]
            value_recorded_liability = budget["recorded_liability"] == nil  ? 0 : budget["recorded_liability"]
            value_kassa = budget["kassa"] == nil  ? 0 : budget["kassa"]
            value_procent = value_consolidate_units == 0 ? 0 : ((value_kassa / value_consolidate_units) * 100).to_i
            value_devation = value_consolidate_units == 0 ? 0 : ((value_kassa / value_consolidate_units)).to_f

            break
          end
        end
        old_value = mapSumTarget["passport_units"] == nil  ? 0 : mapSumTarget["passport_units"]
        mapSumTarget["passport_units"] = value_passport_units+old_value

        old_value = mapSumTarget["consolidate_units"] == nil  ? 0 : mapSumTarget["consolidate_units"]
        mapSumTarget["consolidate_units"] = value_consolidate_units+old_value

        old_value = mapSumTarget["limit_units"] == nil  ? 0 : mapSumTarget["limit_units"]
        mapSumTarget["limit_units"] = value_limit_units+old_value

        old_value = mapSumTarget["recorded_liability"] == nil  ? 0 : mapSumTarget["recorded_liability"]
        mapSumTarget["recorded_liability"] = value_recorded_liability+old_value

        old_value = mapSumTarget["kassa"] == nil  ? 0 : mapSumTarget["kassa"]
        mapSumTarget["kassa"] = value_kassa+old_value

        mapSumTarget["procent"] = value_procent

        old_value_array = array[j][0] == nil ? 0 : array[j][0]
        array[j][0] = value_passport_units+old_value_array

        old_value_array = array[j][1] == nil ? 0 : array[j][1]
        array[j][1] = value_consolidate_units+old_value_array

        old_value_array = array[j][2] == nil ? 0 : array[j][2]
        array[j][2] = value_limit_units+old_value_array

        old_value_array = array[j][3] == nil ? 0 : array[j][3]
        array[j][3] = value_recorded_liability+old_value_array

        old_value_array = array[j][4] == nil ? 0 : array[j][4]
        array[j][4] = value_kassa+old_value_array

        old_value_array = array[j][5] == nil ? 0 : array[j][5]
        array[j][5] = value_procent+old_value_array


        sheet.insert_cell(start_index+j+m, 3, '%.2f' %(value_passport_units/1000000))
        sheet.sheet_data[start_index+j+m][3].change_horizontal_alignment('center')
        sheet.sheet_data[start_index+j+m][3].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][3].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][3].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][3].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][3].change_border(:bottom, 'thin')

        sheet.insert_cell(start_index+j+m, 4, '%.2f' %(value_consolidate_units/1000000))
        sheet.sheet_data[start_index+j+m][4].change_horizontal_alignment('center')
        sheet.sheet_data[start_index+j+m][4].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][4].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][4].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][4].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][4].change_border(:bottom, 'thin')

        sheet.insert_cell(start_index+j+m, 5, '%.2f' %(value_limit_units/1000000))
        sheet.sheet_data[start_index+j+m][5].change_horizontal_alignment('center')
        sheet.sheet_data[start_index+j+m][5].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][5].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][5].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][5].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][5].change_border(:bottom, 'thin')

        sheet.insert_cell(start_index+j+m, 6, '%.2f' %(value_recorded_liability/1000000))
        sheet.sheet_data[start_index+j+m][6].change_horizontal_alignment('center')
        sheet.sheet_data[start_index+j+m][6].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][6].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][6].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][6].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][6].change_border(:bottom, 'thin')

        sheet.insert_cell(start_index+j+m, 7, '%.2f' %(value_kassa/1000000))
        sheet.sheet_data[start_index+j+m][7].change_horizontal_alignment('center')
        sheet.sheet_data[start_index+j+m][7].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][7].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][7].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][7].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][7].change_border(:bottom, 'thin')

        sheet.insert_cell(start_index+j+m, 8, value_procent)
        sheet.sheet_data[start_index+j+m][8].change_horizontal_alignment('center')
        sheet.sheet_data[start_index+j+m][8].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][8].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][8].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][8].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][8].change_border(:bottom, 'thin')

        sheet.insert_cell(start_index+j+m, 9, "")

        sheet.sheet_data[start_index+j+m][9].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][9].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][9].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][9].change_border(:bottom, 'thin')


        # вычисление статуса
        if  value_devation < small_devation.to_f
          status = 1
        elsif   value_devation >= small_devation.to_f && value_devation < no_devation.to_f
          status = 2
        elsif   value_devation == no_devation.to_f
          status = 3
        else status = 0
        end

        if status == 1
           sheet.sheet_data[start_index+j+m][1].change_fill('ff0000')
        elsif status == 2
          sheet.sheet_data[start_index+j+m][1].change_fill('ffd800')
        elsif status == 3
          sheet.sheet_data[start_index+j+m][1].change_fill('0ba53d')
        else
          sheet.sheet_data[start_index+j+m][1].change_fill('d7d7d7')
        end

        count_cost_type += 1
      end

      punkt = "1." + count_target.to_s + "."
      sheet.insert_cell(start_index-1+m, 0, punkt)
      sheet.sheet_data[start_index-1+m][0].change_horizontal_alignment('center')
      sheet.sheet_data[start_index-1+m][0].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][0].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][0].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][0].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][0].change_border(:bottom, 'thin')


      sheet.insert_cell(start_index-1+m, 1, "")
#      sheet.sheet_data[start_index-1+m][1].change_fill('d7d7d7')
      sheet.sheet_data[start_index-1+m][1].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][1].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][1].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][1].change_border(:bottom, 'thin')


      sheet.insert_cell(start_index-1+m, 2, target.name)
      sheet.sheet_data[start_index-1+m][2].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][2].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][2].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][2].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][2].change_border(:bottom, 'thin')
      cell = sheet[start_index-1+m][2]
      cell.change_text_wrap(true)


      value_target =  mapSumTarget["passport_units"] == nil ? 0 : mapSumTarget["passport_units"]
      sheet.insert_cell(start_index-1+m, 3, '%.2f' %(value_target/1000000))

      sheet.sheet_data[start_index-1+m][3].change_horizontal_alignment('center')
      sheet.sheet_data[start_index-1+m][3].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][3].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][3].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][3].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][3].change_border(:bottom, 'thin')


      value_consolidate_units =  mapSumTarget["consolidate_units"] == nil ? 0 : mapSumTarget["consolidate_units"]
      sheet.insert_cell(start_index-1+m, 4, '%.2f' %(value_consolidate_units/1000000))

      sheet.sheet_data[start_index-1+m][4].change_horizontal_alignment('center')
      sheet.sheet_data[start_index-1+m][4].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][4].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][4].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][4].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][4].change_border(:bottom, 'thin')

      value_target =  mapSumTarget["limit_units"] == nil ? 0 : mapSumTarget["limit_units"]
      sheet.insert_cell(start_index-1+m, 5, '%.2f' %(value_target/1000000))

      sheet.sheet_data[start_index-1+m][5].change_horizontal_alignment('center')
      sheet.sheet_data[start_index-1+m][5].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][5].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][5].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][5].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][5].change_border(:bottom, 'thin')

      value_target =  mapSumTarget["recorded_liability"] == nil ? 0 : mapSumTarget["recorded_liability"]
      sheet.insert_cell(start_index-1+m, 6, '%.2f' %(value_target/1000000))

      sheet.sheet_data[start_index-1+m][6].change_horizontal_alignment('center')
      sheet.sheet_data[start_index-1+m][6].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][6].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][6].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][6].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][6].change_border(:bottom, 'thin')


      value_kassa =  mapSumTarget["kassa"] == nil ? 0 : mapSumTarget["kassa"]
      sheet.insert_cell(start_index-1+m, 7, '%.2f' %(value_kassa/1000000))

      sheet.sheet_data[start_index-1+m][7].change_horizontal_alignment('center')
      sheet.sheet_data[start_index-1+m][7].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][7].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][7].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][7].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][7].change_border(:bottom, 'thin')

      value_target =  mapSumTarget["procent"] == nil ? 0 : mapSumTarget["procent"]
      sheet.insert_cell(start_index-1+m, 8, value_target)

      sheet.sheet_data[start_index-1+m][8].change_horizontal_alignment('center')
      sheet.sheet_data[start_index-1+m][8].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][8].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][8].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][8].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][8].change_border(:bottom, 'thin')


      sheet.insert_cell(start_index-1+m, 9, "")

      sheet.sheet_data[start_index-1+m][9].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][9].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][9].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][9].change_border(:bottom, 'thin')

      value_devation = value_consolidate_units == 0 ? 0 : ((value_kassa / value_consolidate_units)).to_f

      # вычисление статуса
      if  value_devation < small_devation.to_f
        status = 1
      elsif   value_devation >= small_devation.to_f && value_devation < no_devation.to_f
        status = 2
      elsif   value_devation == no_devation.to_f
        status = 3
      else status = 0
      end

      if status == 1
        sheet.sheet_data[start_index-1+m][1].change_fill('ff0000')
      elsif status == 2
        sheet.sheet_data[start_index-1+m][1].change_fill('ffd800')
      elsif status == 3
        sheet.sheet_data[start_index-1+m][1].change_fill('0ba53d')
      else
        sheet.sheet_data[start_index-1+m][1].change_fill('d7d7d7')
      end


      m += count_cost_type
    end


    mapBudget = {}
    cost_types.each_with_index do |cost_type, j|

      sheet.insert_cell(start_index+j+m, 0, cost_type.name)
      sheet.sheet_data[start_index+j+m][0].change_vertical_alignment('center')
      sheet.sheet_data[start_index+j+m][0].change_horizontal_alignment('left')
      sheet.insert_cell(start_index+j+m, 1, "")

      sheet.sheet_data[start_index+j+m][0].change_border(:top, 'thin')
      sheet.sheet_data[start_index+j+m][0].change_border(:left, 'thin')
      sheet.sheet_data[start_index+j+m][0].change_border(:right, 'thin')
      sheet.sheet_data[start_index+j+m][0].change_border(:bottom, 'thin')

      sheet.insert_cell(start_index+j+m, 1, "")
#      sheet.sheet_data[start_index+j+m][1].change_fill('d7d7d7')
      sheet.sheet_data[start_index+j+m][1].change_border(:top, 'thin')
      sheet.sheet_data[start_index+j+m][1].change_border(:left, 'thin')
      sheet.sheet_data[start_index+j+m][1].change_border(:right, 'thin')
      sheet.sheet_data[start_index+j+m][1].change_border(:bottom, 'thin')

      sheet.insert_cell(start_index+j+m, 2, "")
      sheet.sheet_data[start_index+j+m][2].change_border(:top, 'thin')
      sheet.sheet_data[start_index+j+m][2].change_border(:left, 'thin')
      sheet.sheet_data[start_index+j+m][2].change_border(:right, 'thin')
      sheet.sheet_data[start_index+j+m][2].change_border(:bottom, 'thin')

      sheet.merge_cells(start_index+j+m, 0, start_index+j+m, 2)

      cell = sheet[start_index+j+m][0]
      cell.change_text_wrap(true)


      sum_budget = 0
      for k in 0..5
        sum = array[j][k] == nil ? 0 : array[j][k]
        sum_budget += sum

        old_value_budget = mapBudget[k] == nil ? 0 : mapBudget[k]
        mapBudget[k] = sum+old_value_budget

        if k == 5
          sheet.insert_cell(start_index+j+m, k+3, 0)
        else
          sheet.insert_cell(start_index+j+m, k+3, '%.2f' %(sum/1000000))
        end

        sheet.sheet_data[start_index+j+m][k+3].change_horizontal_alignment('center')
        sheet.sheet_data[start_index+j+m][k+3].change_vertical_alignment('center')

        sheet.sheet_data[start_index+j+m][k+3].change_border(:top, 'thin')
        sheet.sheet_data[start_index+j+m][k+3].change_border(:left, 'thin')
        sheet.sheet_data[start_index+j+m][k+3].change_border(:right, 'thin')
        sheet.sheet_data[start_index+j+m][k+3].change_border(:bottom, 'thin')
      end
      sheet.insert_cell(start_index+j+m, 9, "")

      sheet.sheet_data[start_index+j+m][9].change_border(:top, 'thin')
      sheet.sheet_data[start_index+j+m][9].change_border(:left, 'thin')
      sheet.sheet_data[start_index+j+m][9].change_border(:right, 'thin')
      sheet.sheet_data[start_index+j+m][9].change_border(:bottom, 'thin')

      value_consolidate_units = array[j][1] == nil ? 0 : array[j][1]
      value_kassa = array[j][4] == nil ? 0 : array[j][4]
      value_devation = value_consolidate_units == 0 ? 0 : ((value_kassa / value_consolidate_units)).to_f

      # вычисление статуса
      if  value_devation < small_devation.to_f
        status = 1
      elsif   value_devation >= small_devation.to_f && value_devation < no_devation.to_f
        status = 2
      elsif   value_devation == no_devation.to_f
        status = 3
      else status = 0
      end

      if status == 1
        sheet.sheet_data[start_index+j+m][1].change_fill('ff0000')
      elsif status == 2
        sheet.sheet_data[start_index+j+m][1].change_fill('ffd800')
      elsif status == 3
        sheet.sheet_data[start_index+j+m][1].change_fill('0ba53d')
      else
        sheet.sheet_data[start_index+j+m][1].change_fill('d7d7d7')
      end

    end


    sheet.insert_cell(start_index-1+m, 0, "Всего по региональному проекту, в том числе:")
    sheet.sheet_data[start_index-1+m][0].change_vertical_alignment('center')
    sheet.sheet_data[start_index-1+m][0].change_horizontal_alignment('left')
    sheet.insert_cell(start_index-1+m, 1, "")
    sheet.insert_cell(start_index-1+m, 2, "")
    sheet.merge_cells(start_index-1+m, 0, start_index-1+m, 2)

    sheet.sheet_data[start_index-1+m][0].change_border(:top, 'thin')
    sheet.sheet_data[start_index-1+m][0].change_border(:left, 'thin')
    sheet.sheet_data[start_index-1+m][0].change_border(:right, 'thin')
    sheet.sheet_data[start_index-1+m][0].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index-1+m][1].change_border(:top, 'thin')
    sheet.sheet_data[start_index-1+m][1].change_border(:left, 'thin')
    sheet.sheet_data[start_index-1+m][1].change_border(:right, 'thin')
    sheet.sheet_data[start_index-1+m][1].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index-1+m][2].change_border(:top, 'thin')
    sheet.sheet_data[start_index-1+m][2].change_border(:left, 'thin')
    sheet.sheet_data[start_index-1+m][2].change_border(:right, 'thin')
    sheet.sheet_data[start_index-1+m][2].change_border(:bottom, 'thin')

    cell = sheet[start_index-1+m][0]
    cell.change_text_wrap(true)


    sum_value = 0
    for n in 0..5
      value =  mapBudget[n] == nil ? 0 : mapBudget[n]
      if n == 5
        sheet.insert_cell(start_index-1+m, n+3, value)
      else
        sheet.insert_cell(start_index-1+m, n+3, '%.2f' %(value/1000000))
      end

      sheet.sheet_data[start_index-1+m][n+3].change_horizontal_alignment('center')
      sheet.sheet_data[start_index-1+m][n+3].change_vertical_alignment('center')

      sheet.sheet_data[start_index-1+m][n+3].change_border(:top, 'thin')
      sheet.sheet_data[start_index-1+m][n+3].change_border(:left, 'thin')
      sheet.sheet_data[start_index-1+m][n+3].change_border(:right, 'thin')
      sheet.sheet_data[start_index-1+m][n+3].change_border(:bottom, 'thin')

      sum_value += value
    end

    sheet.insert_cell(start_index-1+m, 9, "")

    sheet.sheet_data[start_index-1+m][9].change_border(:top, 'thin')
    sheet.sheet_data[start_index-1+m][9].change_border(:left, 'thin')
    sheet.sheet_data[start_index-1+m][9].change_border(:right, 'thin')
    sheet.sheet_data[start_index-1+m][9].change_border(:bottom, 'thin')

  rescue Exception => e
    Rails.logger.info(e.message)
  end


  def generate_status_achievement_sheet

    no_devation =  Setting.find_by(name: 'no_devation').value
    small_devation =  Setting.find_by(name: 'small_devation').value

    sheet = @workbook['Статус достижения результатов']

    data_row = 3
    incriment = 0
    status_result = 0
    id_type_result = Enumeration.find_by(name: I18n.t(:default_result)).id
    targets = Target.where(project_id: @project.id, type_id: id_type_result, is_approve: true)
    targets.each_with_index do |target, i|

      result = get_value_results(target.id.to_s)

      factQuarterTargetValue = result["fact_quarter4_value"].to_i != 0 ? result["fact_quarter4_value"] : ( result["fact_quarter3_value"].to_i != 0 ? target["fact_quarter3_value"] : (target["fact_quarter2_value"].to_i != 0 ? target["fact_quarter2_value"] : (target["fact_quarter1_value"].to_i != 0 ? target["fact_quarter1_value"] : 0)) )
      procent = '%.2f' %(result["plan_year_value"].to_i == 0 ? 0 : (factQuarterTargetValue.to_f / result["plan_year_value"].to_f )*100)
      devation = procent.to_f / 100


      sheet.insert_cell(data_row + i + incriment, 1, "")
      if devation < small_devation.to_f
        sheet.sheet_data[data_row + i+ incriment][1].change_fill('ff0000')
        status_result = 1
      elsif (devation >= small_devation.to_f && devation >  no_devation.to_f)
        sheet.sheet_data[data_row + i+ incriment][1].change_fill('ffd800')
        if status_result != 1
          status_result = 2
        end
      elsif devation  == no_devation.to_f
        sheet.sheet_data[data_row + i+ incriment][1].change_fill('0ba53d')
        if status_result != 1 && status_result != 2
          status_result = 3
        end
      else
        sheet.sheet_data[data_row + i+ incriment][1].change_fill('d7d7d7')
      end


      status = get_status_achievement(target.id.to_s)
      sheet.insert_cell(data_row + i + incriment, 0, i+1)

      sheet.insert_cell(data_row + i + incriment, 2, status["name"])
      sheet.insert_cell(data_row + i + incriment, 3, "")
      sheet.insert_cell(data_row + i + incriment, 4, "")
      sheet.insert_cell(data_row + i + incriment, 5, "")
      sheet.insert_cell(data_row + i + incriment, 6, "")
      sheet.insert_cell(data_row + i + incriment, 7, "")
      sheet.insert_cell(data_row + i + incriment, 8, "")

      incriment += 1

      sheet.insert_cell(data_row + i + incriment, 0, "")
      sheet.insert_cell(data_row + i + incriment, 1, "")
      sheet.insert_cell(data_row + i + incriment, 2, "")
      sheet.insert_cell(data_row + i + incriment, 3, "")

      sheet.insert_cell(data_row + i + incriment, 8, "")

      #  0ba53d -зеленый
      #  ff0000 -красный
      #  ffd800 -желтый
      #  d7d7d7 - серый
      #{ начало вариантов для 1 цвета
      if  status["ispolneno"].nil?
        sheet.insert_cell(data_row + i + incriment, 4, "0")
        sheet.insert_cell(data_row + i + incriment, 5, "")
        sheet.insert_cell(data_row + i + incriment, 6, "")
        sheet.insert_cell(data_row + i + incriment, 7, "")

        sheet.sheet_data[data_row + i + incriment][4].change_fill('d7d7d7')
        sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 7)

      elsif
        (status["ispolneno"].to_i+status["v_rabote"].to_i) > 0 && status["ne_ispolneno"].to_i == 0 && status["est_riski_critic"].to_i == 0 && status["est_riski_necritic"].to_i == 0
        sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"].to_i+status["v_rabote"].to_i)
        sheet.sheet_data[data_row + i + incriment][4].change_fill('0ba53d')
        sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 7)

      elsif
          (status["ne_ispolneno"].to_i + status["est_riski_critic"].to_i) > 0 && status["ispolneno"].to_i == 0 && status["est_riski_necritic"].to_i == 0 && status["v_rabote"].to_i == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ne_ispolneno"].to_i+ status["est_riski_critic"].to_i)
          sheet.sheet_data[data_row + i + incriment][4].change_fill('ff0000')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 7)

      elsif
          status["est_riski_necritic"].to_i > 0 && status["ispolneno"].to_i == 0 && status["ne_ispolneno"].to_i == 0 && status["v_rabote"].to_i == 0 && status["est_riski_critic"].to_i == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["est_riski_necritic"].to_i)
          sheet.sheet_data[data_row + i + incriment][4].change_fill('ffd800')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 7)
        #} конец вариантов для 1 цвета
        # { начало вариантов для 2 цветов
      elsif
          (status["ispolneno"].to_i+status["v_rabote"].to_i)  > 0 && (status["ne_ispolneno"].to_i+status["est_riski_critic"].to_i) > 0 && status["est_riski_necritic"].to_i == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"].to_i+status["v_rabote"].to_i)
          sheet.sheet_data[data_row + i + incriment][4].change_fill('0ba53d')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 5)

          sheet.insert_cell(data_row + i + incriment, 6, status["ne_ispolneno"].to_i+status["est_riski_critic"].to_i)
          sheet.sheet_data[data_row + i + incriment][6].change_fill('ff0000')
          sheet.merge_cells(data_row + i + incriment, 6, data_row + i + incriment, 7)
      elsif
          (status["ispolneno"].to_i + status["v_rabote"].to_i) > 0 && status["ne_ispolneno"].to_i == 0 && status["est_riski_necritic"].to_i > 0 && status["est_riski_critic"].to_i == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"].to_i+ status["v_rabote"].to_i)
          sheet.sheet_data[data_row + i + incriment][4].change_fill('0ba53d')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 5)

          sheet.insert_cell(data_row + i + incriment, 6, status["est_riski_necritic"].to_i)
          sheet.sheet_data[data_row + i + incriment][6].change_fill('ffd800')
          sheet.merge_cells(data_row + i + incriment, 6, data_row + i + incriment, 7)
      elsif
          status["ispolneno"].to_i == 0 && (status["ne_ispolneno"].to_i+status["est_riski_critic"].to_i) > 0 && status["est_riski_necritic"].to_i > 0 && status["v_rabote"].to_i == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ne_ispolneno"].to_i+status["est_riski_critic"].to_i)
          sheet.sheet_data[data_row + i + incriment][4].change_fill('ff0000')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 5)

          sheet.insert_cell(data_row + i + incriment, 6, status["est_riski_necritic"].to_i)
          sheet.sheet_data[data_row + i + incriment][6].change_fill('ffd800')
          sheet.merge_cells(data_row + i + incriment, 6, data_row + i + incriment, 7)
        #} конец вариантов для 2 цветов
        # { начало вариантов для 3 цветов
      elsif
          (status["ispolneno"].to_i+status["v_rabote"].to_i) > 0 && (status["ne_ispolneno"].to_i+status["est_riski_critic"].to_i) > 0 && status["est_riski_necritic"].to_i > 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"].to_i+status["v_rabote"].to_i)
          sheet.sheet_data[data_row + i + incriment][4].change_fill('0ba53d')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 5)

          sheet.insert_cell(data_row + i + incriment, 6, status["ne_ispolneno"].to_i+status["est_riski_critic"].to_i)
          sheet.sheet_data[data_row + i + incriment][6].change_fill('ff0000')
          sheet.insert_cell(data_row + i + incriment, 7, status["est_riski_necritic"].to_i)
          sheet.sheet_data[data_row + i + incriment][7].change_fill('ffd800')
      end


      incriment += 1

      sheet.insert_cell(data_row + i + incriment, 0, "")
      sheet.insert_cell(data_row + i + incriment, 1, "")
      sheet.insert_cell(data_row + i + incriment, 2, "")
      sheet.insert_cell(data_row + i + incriment, 3, "")
      sheet.insert_cell(data_row + i + incriment, 4, "")
      sheet.insert_cell(data_row + i + incriment, 5, "")
      sheet.insert_cell(data_row + i + incriment, 6, "")
      sheet.insert_cell(data_row + i + incriment, 7, "")
      sheet.insert_cell(data_row + i + incriment, 8, "")

      sheet.merge_cells(data_row + i + incriment-2, 0, data_row + i + incriment, 0)
      sheet.merge_cells(data_row + i + incriment-2, 1, data_row + i + incriment, 1)
      sheet.merge_cells(data_row + i + incriment-2, 2, data_row + i + incriment, 2)

      #устанавливаем рамку для ячейки
      sheet.sheet_data[data_row + i + incriment-2][0].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment-2][0].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment-1][0].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment-1][0].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment][0].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment][0].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment][0].change_border(:bottom, 'thin')

      sheet.sheet_data[data_row + i + incriment-2][1].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment-2][1].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment-1][1].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment-1][1].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment][1].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment][1].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment][1].change_border(:bottom, 'thin')

      sheet.sheet_data[data_row + i + incriment-2][2].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment-2][2].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment-1][2].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment-1][2].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment][2].change_border(:left, 'thin')
      sheet.sheet_data[data_row + i + incriment][2].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment][2].change_border(:bottom, 'thin')

      sheet.sheet_data[data_row + i + incriment-2][8].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment-1][8].change_border(:right, 'thin')
      sheet.sheet_data[data_row + i + incriment][8].change_border(:right, 'thin')

      sheet.sheet_data[data_row + i + incriment][3].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i + incriment][4].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i + incriment][5].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i + incriment][6].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i + incriment][7].change_border(:bottom, 'thin')
      sheet.sheet_data[data_row + i + incriment][8].change_border(:bottom, 'thin')
    end


    #  0ba53d -зеленый
    #  ff0000 -красный
    #  ffd800 -желтый
    #  d7d7d7 - серый

    # установка цвета статуса для результатов на титульном листе
    sheet = @workbook['Титульный лист']
    if status_result == 1
      sheet.sheet_data[27][17].change_fill('ff0000')
    elsif status_result == 2
      sheet.sheet_data[27][17].change_fill('ffd800')
    elsif status_result == 3
      sheet.sheet_data[27][17].change_fill('0ba53d')
    else
      sheet.sheet_data[27][17].change_fill('d7d7d7')
    end
  rescue Exception => e
    Rails.logger.info(e.message)
  end

  def get_value_targets_indicators

    sql = "with
            prev_year_value as (
             select  pf.target_id, pf.fact_year_value
             from v_plan_fact_quarterly_target_values as pf
             where pf.year = (extract(year from current_date)-1) and pf.project_id = " + @project.id.to_s + "
            ),
            current_year_value as (
              select  cf.target_id, cf.fact_quarter1_value,
                      cf.fact_quarter2_value, cf.fact_quarter3_value, cf.fact_quarter4_value,
                      cf.plan_year_value
              from v_plan_fact_quarterly_target_values as cf
              where cf.year = extract(year from current_date) and cf.project_id = "+ @project.id.to_s + "
            )
            select t.name, m.short_name as measure_name, coalesce(p.fact_year_value, 0) as fact_year_value,
            coalesce(c.fact_quarter1_value, 0) as fact_quarter1_value, coalesce(c.fact_quarter2_value, 0) as fact_quarter2_value,
            coalesce(c.fact_quarter3_value, 0) as fact_quarter3_value, coalesce(c.fact_quarter4_value, 0) as fact_quarter4_value,
            coalesce(c.plan_year_value, 0) as plan_year_value
            FROM targets t
            left join current_year_value c on c.target_id = t.id
            left join prev_year_value p on p.target_id = t.id
            left join measure_units m on m.id = t.measure_unit_id
            inner join enumerations e on e.id = t.type_id
            where t.is_approve = true and ( e.name = '"+I18n.t(:default_target)+"' or e.name = '"++I18n.t(:default_indicator)+"') and t.project_id = "+ @project.id.to_s


    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array_targets = []

    result.each do |row|
      result_array_targets[index] = row
      index += 1
    end

    result_array_targets
  end


  def get_value_results(target_id)

    sql = "with
            prev_year_value as (
             select  pf.target_id, pf.fact_year_value
             from v_plan_fact_quarterly_target_values as pf
             where pf.year = (extract(year from current_date)-1) and pf.project_id = " + @project.id.to_s + "
            ),
            current_year_value as (
              select  cf.target_id, cf.fact_quarter1_value,
                      cf.fact_quarter2_value, cf.fact_quarter3_value, cf.fact_quarter4_value,
                      cf.plan_year_value
              from v_plan_fact_quarterly_target_values as cf
              where cf.year = extract(year from current_date) and cf.project_id = "+ @project.id.to_s + "
            )
            select t.name, m.short_name as measure_name, coalesce(p.fact_year_value, 0) as fact_year_value,
            coalesce(c.fact_quarter1_value, 0) as fact_quarter1_value, coalesce(c.fact_quarter2_value, 0) as fact_quarter2_value,
            coalesce(c.fact_quarter3_value, 0) as fact_quarter3_value, coalesce(c.fact_quarter4_value, 0) as fact_quarter4_value,
            coalesce(c.plan_year_value, 0) as plan_year_value
            FROM targets t
            left join current_year_value c on c.target_id = t.id
            left join prev_year_value p on p.target_id = t.id
            left join measure_units m on m.id = t.measure_unit_id
            inner join enumerations e on e.id = t.type_id
            where t.is_approve = true and e.name = '"+I18n.t(:default_result)+"' and t.id = "+target_id +" and t.project_id = "+ @project.id.to_s


    result_sql = ActiveRecord::Base.connection.execute(sql)

    result = result_sql[0]
  end



  def generate_status_execution_budgets_sheet

    result_fed_budjet = fed_budget_data
    result_reg_budjet = reg_budget_data
    result_other_budjet = other_budget_data

    sheet = @workbook['Статус исполнения бюджета']
    sheet[3][0].change_contents(Date.today.strftime("%d.%m.%Y"))
    sheet[4][1].change_contents('%.2f' %(result_fed_budjet[3]/1000000))

    sheet[4][6].change_contents(Date.today.strftime("%d.%m.%Y"))
    sheet[5][7].change_contents('%.2f' %(result_reg_budjet[3]/1000000))

    sheet[3][11].change_contents(Date.today.strftime("%d.%m.%Y"))
    sheet[4][12].change_contents('%.2f' %(result_other_budjet[3]/1000000))

    sheetDataDiagram = @workbook['Данные для диаграмм']
     @budjets = AllBudgetsHelper.cost_by_project @project

    sheetDataDiagram[3][4].raw_value = result_fed_budjet[0].to_f
    sheetDataDiagram[4][4].raw_value = result_fed_budjet[1].to_f
    sheetDataDiagram[5][4].raw_value = result_fed_budjet[2].to_f

    sheetDataDiagram[3][9].raw_value = result_reg_budjet[0].to_f
    sheetDataDiagram[4][9].raw_value = result_reg_budjet[1].to_f
    sheetDataDiagram[5][9].raw_value = result_reg_budjet[2].to_f

    sheetDataDiagram[3][14].raw_value = result_other_budjet[0].to_f
    sheetDataDiagram[4][14].raw_value = result_other_budjet[1].to_f
    sheetDataDiagram[5][14].raw_value = result_other_budjet[2].to_f

#    sheetDataDiagram[3][4].change_contents(result_fed_budjet[0])
#    sheetDataDiagram[4][4].change_contents(result_fed_budjet[1])
#    sheetDataDiagram[5][4].change_contents(result_fed_budjet[2])

#    sheetDataDiagram[3][9].change_contents(result_reg_budjet[0])
#    sheetDataDiagram[4][9].change_contents(result_reg_budjet[1])
#    sheetDataDiagram[5][9].change_contents(result_reg_budjet[2])

#    sheetDataDiagram[3][14].change_contents(result_other_budjet[0])
#    sheetDataDiagram[4][14].change_contents(result_other_budjet[1])
#    sheetDataDiagram[5][14].change_contents(result_other_budjet[2])


    no_devation =  Setting.find_by(name: 'no_devation').value
    small_devation =  Setting.find_by(name: 'small_devation').value

    fed_devation = result_fed_budjet[0] / result_fed_budjet[3]
    reg_devation = result_fed_budjet[0] / result_reg_budjet[3]
    other_devation = result_fed_budjet[0] / result_other_budjet[3]

    if  fed_devation < small_devation.to_f
      status_fed = 1
    elsif   fed_devation >= small_devation.to_f && fed_devation < no_devation.to_f
      status_fed = 2
    elsif   fed_devation == no_devation.to_f
      status_fed = 3
    else status_fed = 0
    end

    if  reg_devation < small_devation.to_f
      status_reg = 1
    elsif   reg_devation >= small_devation.to_f && reg_devation < no_devation.to_f
      status_reg = 2
    elsif   reg_devation == no_devation.to_f
      status_reg = 3
    else status_reg = 0
    end

    if  other_devation < small_devation.to_f
      status_other = 1
    elsif   other_devation >= small_devation.to_f && other_devation < no_devation.to_f
      status_other = 2
    elsif   other_devation == no_devation.to_f
      status_other = 3
    else status_other = 0
    end

    if status_fed == 3 && status_reg == 3 && status_other == 3
      status = 3
    elsif status_fed == 1 || status_reg == 1 || status_other == 1
      status = 1
    elsif status_fed == 2 || status_reg == 2 || status_other == 2
      status = 2
    else status  = 0
    end

    #  0ba53d -зеленый
    #  ff0000 -красный
    #  ffd800 -желтый
    #  d7d7d7 - серый

    # установка цвета статуса для бюджета на титульном листе
    sheetTitle = @workbook['Титульный лист']
    if status == 1
      sheetTitle.sheet_data[27][13].change_fill('ff0000')

    elsif status == 2
      sheetTitle.sheet_data[27][13].change_fill('ffd800')
    elsif status == 3
      sheetTitle.sheet_data[27][13].change_fill('0ba53d')
    else
      sheetTitle.sheet_data[27][13].change_fill('d7d7d7')
    end
  rescue Exception => e
    Rails.logger.info(e.message)
  end

  def generate_dynamic_achievement_kt_sheet
    sheet = @workbook['Динамика достижения КТ']

    sheetDataDiagram = @workbook['Данные для диаграмм']

    result_array = get_month_kt_values

    not_time = 0
    riski = 0
    index = 0

    result_array.each do |kt|
        if  kt["month"].to_i == 1
          sheetDataDiagram.insert_cell(9, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(9, 3, kt["value"].to_i)
          sheetDataDiagram[9][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[9][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 2
          sheetDataDiagram.insert_cell(10, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(10, 3, kt["value"].to_i)
          sheetDataDiagram[10][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[10][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 3
          sheetDataDiagram.insert_cell(11, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(11, 3, kt["value"].to_i)
          sheetDataDiagram[11][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[11][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 4
          sheetDataDiagram.insert_cell(12, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(12, 3, kt["value"].to_i)
          sheetDataDiagram[12][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[12][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 5
          sheetDataDiagram.insert_cell(13, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(13, 3, kt["value"].to_i)
          sheetDataDiagram[13][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[13][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 6
          sheetDataDiagram.insert_cell(14, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(14, 3, kt["value"].to_i)
          sheetDataDiagram[14][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[14][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 7
          sheetDataDiagram.insert_cell(15, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(15, 3, kt["value"].to_i)
          sheetDataDiagram[15][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[15][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 8
          sheetDataDiagram.insert_cell(16, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(16, 3, kt["value"].to_i)
          sheetDataDiagram[16][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[16][3].raw_value = kt["value"].to_f

        elsif kt["month"].to_i == 9
          sheetDataDiagram.insert_cell(17, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(17, 3, kt["value"].to_i)
          sheetDataDiagram[17][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[17][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 10
          sheetDataDiagram.insert_cell(18, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(18, 3, kt["value"].to_i)
          sheetDataDiagram[18][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[18][3].raw_value = kt["value"].to_f

        elsif kt["month"].to_i == 11
          sheetDataDiagram.insert_cell(19, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(19, 3, kt["value"].to_i)
          sheetDataDiagram[19][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[19][3].raw_value = kt["value"].to_f
        elsif kt["month"].to_i == 12
          sheetDataDiagram.insert_cell(20, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(20, 3, kt["value"].to_i)
          sheetDataDiagram[20][2].raw_value = kt["plan_value"].to_f
          sheetDataDiagram[20][3].raw_value = kt["value"].to_f
        end

        not_time += kt["not_time"].to_i
        riski += kt["riski"].to_i

        index += 1
    end

    sheet[2][6].change_contents(not_time)
    sheet[4][6].change_contents(riski)

    #  0ba53d -зеленый
    #  ff0000 -красный
    #  ffd800 -желтый
    #  d7d7d7 - серый

    # установка цвета статуса для контрольных точек на титульном листе
    sheetTitle = @workbook['Титульный лист']
    if not_time > 0
      sheetTitle.sheet_data[27][21].change_fill('ff0000')
    elsif riski > 0
      sheetTitle.sheet_data[27][21].change_fill('ffd800')
    elsif index > 0
      sheetTitle.sheet_data[27][21].change_fill('0ba53d')
    else
      sheetTitle.sheet_data[27][21].change_fill('d7d7d7')
    end
  rescue Exception => e
    Rails.logger.info(e.message)
  end

  def generate_info_achievement_rktm_sheet
    sheet = @workbook['Cведения о достижении РКТМ']

    @id_type_target = Enumeration.find_by(name: I18n.t(:default_target)).id
    @id_type_result = Enumeration.find_by(name: I18n.t(:default_result)).id
    @id_type_kt = Type.find_by(name: I18n.t(:default_type_milestone)).id
    @id_type_task = Type.find_by(name: I18n.t(:default_type_task)).id

    str_ids_kt = ""
    start_index = 4
    parent_id = 0
    target_id = 0
    index = 0
    numberResult= 1
    k = 0
    work_packages_id = 0
    numberKT = 0
    map = {}
    targetCountParent = 0
    targetCount = 0
    common_count = 0
    numberTarget = ""
    get_result.each_with_index do |result, i|

      if result["parent_id"] != parent_id && result["parent_id"]!=0
        targetCount += 1
        numberTarget = (targetCount).to_s+"."

        username = ''
        begin
          username = result["result_assigned"] == nil ? "" : User.find(result["result_assigned"]).name(:lastname_f_p)
        rescue Exception => e
          Rails.logger.info(e.message)
        end
        start_date = result["basic_date"] == nil ? "" : result["basic_date"].to_date.strftime("%d.%m.%Y")
        due_date = result["result_due_date"] == nil ? "" : result["result_due_date"].to_date.strftime("%d.%m.%Y")
        if start_date == "" && due_date !=""
           period_plan = due_date
        elsif start_date != "" && due_date ==""
          period_plan = start_date
        elsif start_date == "" && due_date ==""
          period_plan =""
        else
          period_plan = start_date+" - "+ due_date
        end

        target  = nil
        begin
          target = Target.find(result["parent_id"])
        rescue Exception => e
          Rails.logger.info(e.message)
        end

        attch = Attachment.where(container_type: 'WorkPackage', container_id: result['id'])
        file_str = ""
        attch.map do |a|
          file_str += a.filename + ", "
        end
        file_str = attch.count > 0 ? file_str.first(-2) : ""
        sheet.insert_cell(start_index+i+k, 0, numberTarget)
        sheet.insert_cell(start_index+i+k, 1, result["control_level"])
        sheet.insert_cell(start_index+i+k, 2, "")
        sheet.insert_cell(start_index+i+k, 3, target ? target.name : '')
        sheet.insert_cell(start_index+i+k, 4, period_plan)
        sheet.insert_cell(start_index+i+k, 5, "")
        sheet.insert_cell(start_index+i+k, 6, username)
        sheet.insert_cell(start_index+i+k, 7, file_str)
        sheet.insert_cell(start_index+i+k, 8, result["comment"])


        #  0ba53d -зеленый
        #  ff0000 -красный
        #  ffd800 -желтый
        #  d7d7d7 - серый

        if result["due_date"] == nil || result["due_date"] == ""
          sheet.sheet_data[start_index+i+k][2].change_fill('d7d7d7')
        elsif  Date.today > result["due_date"].to_date
          sheet.sheet_data[start_index+i+k][2].change_fill('ff0000')
        else
          sheet.sheet_data[start_index+i+k][2].change_fill('0ba53d')
        end

        sheet[start_index+i+k][1].change_text_wrap(true)
        sheet[start_index+i+k][2].change_text_wrap(true)
        sheet[start_index+i+k][3].change_text_wrap(true)
        sheet[start_index+i+k][4].change_text_wrap(true)
        sheet[start_index+i+k][5].change_text_wrap(true)
        sheet[start_index+i+k][6].change_text_wrap(true)
        sheet[start_index+i+k][7].change_text_wrap(true)
        sheet[start_index+i+k][8].change_text_wrap(true)



        sheet.sheet_data[start_index+i+k][0].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][0].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][0].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][0].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][1].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][1].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][1].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][1].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][2].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][2].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][2].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][2].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][3].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][3].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][3].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][3].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][4].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][4].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][4].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][4].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][5].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][5].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][5].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][5].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][6].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][6].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][6].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][6].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][7].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][7].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][7].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][7].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][8].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][8].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][8].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][8].change_border(:bottom, 'thin')

        parent_id = result["parent_id"]
        start_index += 1
        index += 1
        map[0] = index
        targetCountParent = 0
        common_count = start_index+i+k
      end




      if result["target_id"] != target_id
        targetCountParent += 1
        if result["parent_id"] == 0
          targetCount += 1
          numberResult = targetCount.to_s+"."
        elsif
        numberResult = numberTarget+targetCountParent.to_s+"."
        end

        username = ''
        begin
          username = result["result_assigned"] == nil ? "" : User.find(result["result_assigned"]).name(:lastname_f_p)
        rescue Exception => e
          Rails.logger.info(e.message)
        end
        start_date = result["basic_date"] == nil ? "" : result["basic_date"].to_date.strftime("%d.%m.%Y")
        due_date = result["result_due_date"] == nil ? "" : result["result_due_date"].to_date.strftime("%d.%m.%Y")

        if start_date == "" && due_date !=""
          period_plan = due_date
        elsif start_date != "" && due_date ==""
          period_plan = start_date
        elsif start_date == "" && due_date ==""
          period_plan =""
        else
          period_plan = start_date+" - "+ due_date
        end


        sheet.insert_cell(start_index+i+k, 0, numberResult)
        sheet.insert_cell(start_index+i+k, 1, result["control_level"])
        sheet.insert_cell(start_index+i+k, 2, "")
        sheet.insert_cell(start_index+i+k, 3, result["name"])
        sheet.insert_cell(start_index+i+k, 4, period_plan)
        sheet.insert_cell(start_index+i+k, 5, "")
        sheet.insert_cell(start_index+i+k, 6, username)
        sheet.insert_cell(start_index+i+k, 7, result["comment"])


        #  0ba53d -зеленый
        #  ff0000 -красный
        #  ffd800 -желтый
        #  d7d7d7 - серый

        if result["due_date"] == nil || result["due_date"] == ""
          sheet.sheet_data[start_index+i+k][2].change_fill('d7d7d7')
        elsif  Date.today > result["due_date"].to_date
          sheet.sheet_data[start_index+i+k][2].change_fill('ff0000')
        else
          sheet.sheet_data[start_index+i+k][2].change_fill('0ba53d')
        end


        sheet[start_index+i+k][1].change_text_wrap(true)
        sheet[start_index+i+k][2].change_text_wrap(true)
        sheet[start_index+i+k][3].change_text_wrap(true)
        sheet[start_index+i+k][4].change_text_wrap(true)
        sheet[start_index+i+k][5].change_text_wrap(true)
        sheet[start_index+i+k][6].change_text_wrap(true)
        sheet[start_index+i+k][7].change_text_wrap(true)


        sheet.sheet_data[start_index+i+k][0].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][0].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][0].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][0].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][1].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][1].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][1].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][1].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][2].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][2].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][2].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][2].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][3].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][3].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][3].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][3].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][4].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][4].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][4].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][4].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][5].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][5].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][5].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][5].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][6].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][6].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][6].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][6].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+k][7].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+k][7].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+k][7].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+k][7].change_border(:bottom, 'thin')

        target_id = result["target_id"]
        start_index += 1
        index += 1
        numberKT = 0
        map[1] = index
        common_count = start_index+i+k
      end

      if result["work_packages_id"] != nil
        if result["work_packages_id"] != work_packages_id
          username = ''
          begin
            username = result["user_id"] == nil ? "" : User.find(result["user_id"]).name(:lastname_f_p)
          rescue Exception => e
            Rails.logger.info(e.message)
          end
          start_date = result["start_date"] == nil ? "" : result["start_date"].to_date.strftime("%d.%m.%Y")
          due_date = result["due_date"] == nil ? "" : result["due_date"].to_date.strftime("%d.%m.%Y")
          first_start_date = result["first_start_date"] == nil ? "" : result["first_start_date"].to_date.strftime("%d.%m.%Y")
          fact_due_date = result["fact_due_date"] == nil ? "" : result["fact_due_date"].to_date.strftime("%d.%m.%Y")

          if start_date == "" && due_date !=""
            period_plan = due_date
          elsif start_date != "" && due_date ==""
            period_plan = start_date
          elsif start_date == "" && due_date ==""
            period_plan =""
          else
            period_plan = start_date+" - "+ due_date
          end

          if first_start_date == "" && start_date != ""
            first_start_date = start_date
          end
          if fact_due_date == "" && due_date != ""
            fact_due_date = due_date
          end

          if first_start_date == "" && fact_due_date !=""
            period_fact = fact_due_date
          elsif first_start_date != "" && fact_due_date ==""
            period_fact = first_start_date
          elsif first_start_date == "" && fact_due_date ==""
            period_fact =""
          else
            period_fact = first_start_date+" - "+ fact_due_date
          end

          numberKT += 1
          numberResultKt = numberResult+numberKT.to_s+"."
          sheet.insert_cell(start_index+i+k, 0, numberResultKt)
          sheet.insert_cell(start_index+i+k, 1, result["control_level"])
          sheet.insert_cell(start_index+i+k, 2, "")
          sheet.insert_cell(start_index+i+k, 3, result["subject"])
          sheet.insert_cell(start_index+i+k, 4, period_plan)
          sheet.insert_cell(start_index+i+k, 5, period_fact)
          sheet.insert_cell(start_index+i+k, 6, username)
          sheet.insert_cell(start_index+i+k, 7, result["comment"])


          #  0ba53d -зеленый
          #  ff0000 -красный
          #  ffd800 -желтый
          #  d7d7d7 - серый

          if result["due_date"] == nil || result["due_date"] == ""
            sheet.sheet_data[start_index+i+k][2].change_fill('d7d7d7')
          elsif  Date.today > result["due_date"].to_date
            sheet.sheet_data[start_index+i+k][2].change_fill('ff0000')
          else
            sheet.sheet_data[start_index+i+k][2].change_fill('0ba53d')
          end


          sheet[start_index+i+k][1].change_text_wrap(true)
          sheet[start_index+i+k][2].change_text_wrap(true)
          sheet[start_index+i+k][3].change_text_wrap(true)
          sheet[start_index+i+k][4].change_text_wrap(true)
          sheet[start_index+i+k][5].change_text_wrap(true)
          sheet[start_index+i+k][6].change_text_wrap(true)
          sheet[start_index+i+k][7].change_text_wrap(true)


          sheet.sheet_data[start_index+i+k][0].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+k][0].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+k][0].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+k][0].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+k][1].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+k][1].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+k][1].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+k][1].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+k][2].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+k][2].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+k][2].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+k][2].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+k][3].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+k][3].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+k][3].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+k][3].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+k][4].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+k][4].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+k][4].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+k][4].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+k][5].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+k][5].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+k][5].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+k][5].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+k][6].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+k][6].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+k][6].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+k][6].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+k][7].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+k][7].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+k][7].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+k][7].change_border(:bottom, 'thin')

          map[2] = numberKT
          common_count = start_index+i+k
        end


        work_packages_id = result["work_packages_id"] == nil ? "0" : result["work_packages_id"].to_s

        str_ids_kt = str_ids_kt == "" ? work_packages_id.to_s : str_ids_kt += ","+work_packages_id.to_s

        ktTasks = get_kt_tasks(work_packages_id)
        if ktTasks.count > 0
          k += 1
        end
        level = 2
        index2 = 0
        ktTasks.each_with_index do |ktTask, j|
          username = ''
          begin
            user = User.find(ktTask["user_id"])
            username = user.name(:lastname_f_p)
          rescue Exception => e
            Rails.logger.info(e.message)
          end
          start_date = ktTask["start_date"] == nil ? "" : ktTask["start_date"].to_date.strftime("%d.%m.%Y")
          due_date = ktTask["due_date"] == nil ? "" : ktTask["due_date"].to_date.strftime("%d.%m.%Y")
          first_start_date = ktTask["first_start_date"] == nil ? "" : ktTask["first_start_date"].to_date.strftime("%d.%m.%Y")
          fact_due_date = ktTask["fact_due_date"] == nil ? "" : ktTask["fact_due_date"].to_date.strftime("%d.%m.%Y")

          if start_date == "" && due_date !=""
            period_plan = due_date
          elsif start_date != "" && due_date ==""
            period_plan = start_date
          elsif start_date == "" && due_date ==""
            period_plan =""
          else
            period_plan = start_date+" - "+ due_date
          end

          if first_start_date == "" && start_date != ""
            first_start_date = start_date
          end
          if fact_due_date == "" && due_date != ""
            fact_due_date = due_date
          end

          if first_start_date == "" && fact_due_date !=""
            period_fact = fact_due_date
          elsif first_start_date != "" && fact_due_date ==""
            period_fact = first_start_date
          elsif first_start_date == "" && fact_due_date ==""
            period_fact =""
          else
            period_fact = first_start_date+" - "+ fact_due_date
          end

          if ktTask["level"] > level
            level = ktTask["level"]
            index2 = 1
            map[level] = index2
          elsif ktTask["level"] < level
            level = ktTask["level"]
            map[level] = map[level]+1
            index2 = map[level]
          else
            index2 += 1
            map[level] = index2
          end

          punkt = numberResultKt
          for l in 3..level
            punkt += map[l].to_s + "."
          end


          sheet.insert_cell(start_index+i+j+k, 0, punkt)
          sheet.insert_cell(start_index+i+j+k, 1, ktTask["control_level"])
          sheet.insert_cell(start_index+i+j+k, 2, "")
          sheet.insert_cell(start_index+i+j+k, 3, ktTask["subject"])
          sheet.insert_cell(start_index+i+j+k, 4, period_plan)
          sheet.insert_cell(start_index+i+j+k, 5, period_fact)
          sheet.insert_cell(start_index+i+j+k, 6, username)
          sheet.insert_cell(start_index+i+j+k, 7, "")


          #  0ba53d -зеленый
          #  ff0000 -красный
          #  ffd800 -желтый
          #  d7d7d7 - серый
          if ktTask["is_closed"] == true
            sheet.sheet_data[start_index+i+j+k][2].change_fill('0ba53d')
          elsif ktTask["due_date"] == nil || ktTask["due_date"] == ""
            sheet.sheet_data[start_index+i+j+k][2].change_fill('d7d7d7')
          elsif  Date.today > ktTask["due_date"].to_date
            sheet.sheet_data[start_index+i+j+k][2].change_fill('ff0000')
          else
            sheet.sheet_data[start_index+i+j+k][2].change_fill('0ba53d')
          end

          sheet[start_index+i+j+k][1].change_text_wrap(true)
          sheet[start_index+i+j+k][2].change_text_wrap(true)
          sheet[start_index+i+j+k][3].change_text_wrap(true)
          sheet[start_index+i+j+k][4].change_text_wrap(true)
          sheet[start_index+i+j+k][5].change_text_wrap(true)
          sheet[start_index+i+j+k][6].change_text_wrap(true)
          sheet[start_index+i+j+k][7].change_text_wrap(true)

          sheet.sheet_data[start_index+i+j+k][0].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+j+k][0].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+j+k][0].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+j+k][0].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+j+k][1].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+j+k][1].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+j+k][1].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+j+k][1].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+j+k][2].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+j+k][2].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+j+k][2].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+j+k][2].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+j+k][3].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+j+k][3].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+j+k][3].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+j+k][3].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+j+k][4].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+j+k][4].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+j+k][4].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+j+k][4].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+j+k][5].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+j+k][5].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+j+k][5].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+j+k][5].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+j+k][6].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+j+k][6].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+j+k][6].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+j+k][6].change_border(:bottom, 'thin')

          sheet.sheet_data[start_index+i+j+k][7].change_border(:top, 'thin')
          sheet.sheet_data[start_index+i+j+k][7].change_border(:left, 'thin')
          sheet.sheet_data[start_index+i+j+k][7].change_border(:right, 'thin')
          sheet.sheet_data[start_index+i+j+k][7].change_border(:bottom, 'thin')

          common_count = start_index+i+j+k
        end

        if ktTasks.count != 0
          k += ktTasks.count - 1
        end
      else
        start_index -= 1
      end

    end

    start_index = common_count == 0 ? 3 : common_count

    start_punkt = targetCount
    k = 0
    map = {}
    map[1] = start_punkt

    str_ids_kt = str_ids_kt == "" ? "0" : str_ids_kt
    kt_task_no_relations = get_kt_task_no_relation(str_ids_kt)
    kt_task_no_relations.each_with_index do |kt_task_no_relation, i|
      start_punkt += 1
      work_packages_id = kt_task_no_relation["id"].to_s
      ktTasks = get_kt_tasks_parent(work_packages_id)
      if ktTasks.count > 0
        k += 1
      end
      level = 2
      index2 = 0
      ktTasks.each_with_index do |ktTask, j|
        username = ''
        begin
          user = User.find(ktTask["user_id"])
          username = user.name(:lastname_f_p)
        rescue Exception => e
          Rails.logger.info(e.message)
        end
        start_date = ktTask["start_date"] == nil ? "" : ktTask["start_date"].to_date.strftime("%d.%m.%Y")
        due_date = ktTask["due_date"] == nil ? "" : ktTask["due_date"].to_date.strftime("%d.%m.%Y")
        first_start_date = ktTask["first_start_date"] == nil ? "" : ktTask["first_start_date"].to_date.strftime("%d.%m.%Y")
        fact_due_date = ktTask["fact_due_date"] == nil ? "" : ktTask["fact_due_date"].to_date.strftime("%d.%m.%Y")

        if start_date == "" && due_date !=""
          period_plan = due_date
        elsif start_date != "" && due_date ==""
          period_plan = start_date
        elsif start_date == "" && due_date ==""
          period_plan =""
        else
          period_plan = start_date+" - "+ due_date
        end

        if first_start_date == "" && start_date != ""
          first_start_date = start_date
        end
        if fact_due_date == "" && due_date != ""
          fact_due_date = due_date
        end

        if first_start_date == "" && fact_due_date !=""
          period_fact = fact_due_date
        elsif first_start_date != "" && fact_due_date ==""
          period_fact = first_start_date
        elsif first_start_date == "" && fact_due_date ==""
          period_fact =""
        else
          period_fact = first_start_date+" - "+ fact_due_date
        end

        if ktTask["level"] > level
          level = ktTask["level"]
          index2 = 1
          map[level] = index2
        elsif ktTask["level"]  < level
          level = ktTask["level"]
          map[level] = map[level]+1
          index2 = map[level]
        else
          index2 += 1
          map[level] = index2
        end

        punkt = map[1].to_s + "."
        for l in 2..level
          punkt += map[l].to_s + "."
        end

        attch = Attachment.where(container_type: 'WorkPackage',container_id: ktTask["work_packages_id"])
        file_str = ""
        attch.map do |a|
          file_str += a.filename + ", "
        end
        file_str = attch.count > 0 ? file_str.first(-2) : ""
        com_str = ""
        cmmnt = Journal.where(journable_type: 'WorkPackage', journable_id: ktTask["work_packages_id"])
        cmmnt.map do |c|
          com_str += (c.notes.include?("_Обновлено автоматически") or c.notes == nil or c.notes == "") ? "" : "\n" + c.notes
        end

        sheet.insert_cell(start_index+i+j+k, 0, punkt)
        sheet.insert_cell(start_index+i+j+k, 1, ktTask["control_level"])
        sheet.insert_cell(start_index+i+j+k, 2, "")
        sheet.insert_cell(start_index+i+j+k, 3, ktTask["subject"])
        sheet.insert_cell(start_index+i+j+k, 4, period_plan)
        sheet.insert_cell(start_index+i+j+k, 5, period_fact)
        sheet.insert_cell(start_index+i+j+k, 6, username)
        sheet.insert_cell(start_index+i+j+k, 7, file_str)
        sheet.insert_cell(start_index+i+j+k, 8, com_str)

        #  0ba53d -зеленый
        #  ff0000 -красный
        #  ffd800 -желтый
        #  d7d7d7 - серый
        if ktTask["is_closed"] == true
            sheet.sheet_data[start_index+i+j+k][2].change_fill('0ba53d')
        elsif ktTask["due_date"] == nil || ktTask["due_date"] == ""
          sheet.sheet_data[start_index+i+j+k][2].change_fill('d7d7d7')
        elsif  Date.today > ktTask["due_date"].to_date
            sheet.sheet_data[start_index+i+j+k][2].change_fill('ff0000')
        else
          sheet.sheet_data[start_index+i+j+k][2].change_fill('0ba53d')
        end

        sheet[start_index+i+j+k][1].change_text_wrap(true)
        sheet[start_index+i+j+k][2].change_text_wrap(true)
        sheet[start_index+i+j+k][3].change_text_wrap(true)
        sheet[start_index+i+j+k][4].change_text_wrap(true)
        sheet[start_index+i+j+k][5].change_text_wrap(true)
        sheet[start_index+i+j+k][6].change_text_wrap(true)
        sheet[start_index+i+j+k][7].change_text_wrap(true)
        sheet[start_index+i+j+k][8].change_text_wrap(true)

        sheet.sheet_data[start_index+i+j+k][0].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][0].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][0].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][0].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+j+k][1].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][1].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][1].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][1].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+j+k][2].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][2].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][2].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][2].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+j+k][3].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][3].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][3].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][3].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+j+k][4].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][4].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][4].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][4].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+j+k][5].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][5].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][5].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][5].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+j+k][6].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][6].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][6].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][6].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+j+k][7].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][7].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][7].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][7].change_border(:bottom, 'thin')

        sheet.sheet_data[start_index+i+j+k][8].change_border(:top, 'thin')
        sheet.sheet_data[start_index+i+j+k][8].change_border(:left, 'thin')
        sheet.sheet_data[start_index+i+j+k][8].change_border(:right, 'thin')
        sheet.sheet_data[start_index+i+j+k][8].change_border(:bottom, 'thin')

      end

      if ktTasks.count != 0
        k += ktTasks.count - 2
      end


    end
  rescue Exception => e
    Rails.logger.info(e.message)
  end


  def get_result
    sql  = "SELECT t.parent_id, t.id as target_id,t.name, t.result_due_date, t.result_assigned, t.basic_date, w.id as work_packages_id,
               w.subject,
               w.type_id,
               w.start_date,
               w.due_date,
               w.first_start_date,
               w.first_due_date,
               u.id    as user_id,
               ed.name as document,
               cl.code as control_level,
               atch.filename as comment
            FROM targets t
                   INNER JOIN enumerations e ON e.id = t.type_id and e.name = '"+I18n.t(:default_result)+"'
                   LEFT JOIN work_package_targets wt ON wt.target_id = t.id
                   LEFT JOIN work_packages w ON w.id = wt.work_package_id
                   LEFT OUTER JOIN users u ON w.assigned_to_id = u.id
                   LEFT OUTER JOIN enumerations ed ON ed.id = w.required_doc_type_id
                   LEFT OUTER JOIN control_levels cl ON cl.id = w.control_level_id
                   LEFT OUTER JOIN attachments atch ON atch.container_type = 'WorkPackage' and atch.container_id = w.id
            WHERE t.project_id = "+ @project.id.to_s +
      " GROUP BY t.parent_id, t.id, t.name, t.result_due_date, t.result_assigned, t.plan_date, w.id, w.subject, w.type_id, w.start_date, w.due_date, w.first_start_date,  w.first_due_date, u.id, ed.name, cl.code, atch.filename
            ORDER BY t.parent_id desc,  t.id"

    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []
    result.each do |row|
      result_array[index] = row
      index += 1
    end
    result_array
  end

  def get_kt_tasks(work_packages_id)
    sql  = "WITH
            LEVEL AS (
              WITH RECURSIVE r AS (
                SELECT distinct rel.to_id,  CAST (rel.to_id AS VARCHAR (50)) as PATH,1 AS level
                FROM relations rel
                WHERE rel.to_id = " + work_packages_id + "

                UNION

                SELECT distinct rel.to_id,  CAST ( r.PATH ||'->'|| rel.to_id AS VARCHAR(50)),r.level+1 AS level
                FROM relations rel
                       JOIN r ON rel.from_id = r.to_id
                where rel.hierarchy = 1  and follows = 0

                )
                SELECT r.to_id as work_packages_id, r.path, r.level FROM r
            ),
          TASK AS (
            SELECT distinct w.id as work_packages_id,
                            w.subject,
                            w.type_id,
                            w.start_date,
                            w.due_date,
                            w.first_start_date,
                            w.first_due_date,
                            u.id    as user_id,
                            ed.name as document,
                            s.is_closed
            FROM work_packages w
                   LEFT OUTER JOIN users u ON w.assigned_to_id = u.id
                   LEFT OUTER JOIN enumerations ed ON ed.id = w.required_doc_type_id
                   left outer JOIN statuses s on w.status_id = s.id
            WHERE w.id in (
              WITH RECURSIVE r AS (
                SELECT rel.to_id
                FROM relations rel
                WHERE rel.to_id = " + work_packages_id + "

                UNION

                SELECT distinct rel.to_id
                FROM relations rel
                       JOIN r ON rel.from_id = r.to_id
                where rel.hierarchy = 1 and follows = 0

                )
                SELECT r.to_id FROM r
            )
          )
         SELECT t.*, l.level+1 as level, l.path, cl.code as control_level from LEVEL l, TASK t
         INNER JOIN work_packages w ON w.id = t.work_packages_id
         LEFT OUTER JOIN control_levels cl ON cl.id = w.control_level_id

         WHERE l.work_packages_id = t.work_packages_id and l.level <> 1
         ORDER BY  l.path"

    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []
    result.each do |row|
      result_array[index] = row
      index += 1
    end
    result_array
  end


  def get_kt_tasks_parent(work_packages_id)
    sql  = "WITH
            LEVEL AS (
              WITH RECURSIVE r AS (
                SELECT distinct rel.to_id,  CAST (rel.to_id AS VARCHAR (50)) as PATH,1 AS level
                FROM relations rel
                WHERE rel.to_id = " + work_packages_id + "

                UNION

                SELECT distinct rel.to_id,  CAST ( r.PATH ||'->'|| rel.to_id AS VARCHAR(50)),r.level+1 AS level
                FROM relations rel
                       JOIN r ON rel.from_id = r.to_id
                where rel.hierarchy = 1  and follows = 0

                )
                SELECT r.to_id as work_packages_id, r.path, r.level FROM r
            ),
          TASK AS (
            SELECT distinct w.id as work_packages_id,
                            w.subject,
                            w.type_id,
                            w.start_date,
                            w.due_date,
                            w.first_start_date,
                            w.first_due_date,
                            u.id    as user_id,
                            ed.name as document,
                            s.is_closed
            FROM work_packages w
                   LEFT OUTER JOIN users u ON w.assigned_to_id = u.id
                   LEFT OUTER JOIN enumerations ed ON ed.id = w.required_doc_type_id
                   left outer JOIN statuses s on w.status_id = s.id
            WHERE w.id in (
              WITH RECURSIVE r AS (
                SELECT rel.to_id
                FROM relations rel
                WHERE rel.to_id = " + work_packages_id + "

                UNION

                SELECT distinct rel.to_id
                FROM relations rel
                       JOIN r ON rel.from_id = r.to_id
                where rel.hierarchy = 1 and follows = 0

                )
                SELECT r.to_id FROM r
            )
          )
         SELECT t.*, l.level as level, l.path, cl.code as control_level, atch.filename as comment from LEVEL l, TASK t
         INNER JOIN work_packages w ON w.id = t.work_packages_id
         LEFT OUTER JOIN control_levels cl ON cl.id = w.control_level_id
         LEFT JOIN attachments atch ON atch.container_id = t.work_packages_id AND atch.container_type = 'WorkPackage'

         WHERE l.work_packages_id = t.work_packages_id
         ORDER BY  l.path"

    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []
    result.each do |row|
      result_array[index] = row
      index += 1
    end
    result_array
  end


  def get_kt_task_no_relation(str_ids_kt)

    sql  = "SELECT w.*
            FROM work_packages w
            WHERE w.id in (
            SELECT rel.to_id as id
            FROM relations rel
            WHERE rel.to_id  in (
            SELECT id
            from work_packages w
            WHERE id not in
            ("+str_ids_kt+")
            and w.project_id = "+ @project.id.to_s+ " )  and follows = 0
            group by rel.to_id
            having count(id) = 1
            order by rel.to_id )"

    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []
    result.each do |row|
      result_array[index] = row
      index += 1
    end
    result_array
  end



   def fed_budget_data
    cost_objects = CostObject.where(project_id: @project.id)
    total_budget = BigDecimal("0")
    spent = BigDecimal("0")

    cost_objects.each do |cost_object|
      cost_object.cost_entries.each do |cost_entry|
        if cost_entry.cost_type.name == "Федеральный бюджет"
          total_budget += cost_object.budget
          spent += cost_object.spent
        end
      end
    end

    spent
    risk_ispoln = 0
    ostatok = total_budget - spent
    result = []

    result << spent
    result << risk_ispoln
    result << ostatok
    result << total_budget
  end

  def reg_budget_data
    cost_objects = CostObject.where(project_id: @project.id)
    total_budget = BigDecimal("0")
    labor_budget = BigDecimal("0")
    spent = BigDecimal("0")

    cost_objects.each do |cost_object|
      cost_object.cost_entries.each do |cost_entry|
        if cost_entry.cost_type.name == "Региональный бюджет"
          total_budget += cost_object.budget
          labor_budget += cost_object.labor_budget
          spent += cost_object.spent
        end
      end
    end

    spent
    risk_ispoln = 0
    ostatok = total_budget - spent
    result = []

    result << spent
    result << risk_ispoln
    result << ostatok
    result << total_budget
  end

  def other_budget_data
    cost_objects = CostObject.where(project_id: @project.id)
    total_budget = BigDecimal("0")
    material_budget = BigDecimal("0")
    spent = BigDecimal("0")

    cost_objects.each do |cost_object|
      cost_object.cost_entries.each do |cost_entry|
        if cost_entry.cost_type.name != "Региональный бюджет" && cost_entry.cost_type.name != "Федеральный бюджет"
          total_budget += cost_object.budget
          material_budget += cost_object.labor_budget
          spent += cost_object.spent
        end
       end
    end

    spent
    risk_ispoln = 0
    ostatok = total_budget - spent
    result = []

    result << spent
    result << risk_ispoln
    result << ostatok
    result << total_budget
  end


  def get_status_achievement(target_id)
    sql = " with
     stat as (
       select "+ target_id+" as target_id,
              sum(ispolneno)          as ispolneno,
              sum(ne_ispolneno)       as ne_ispolneno,
              sum(est_riski_critic)   as est_riski_critic,
              sum(est_riski_necritic) as est_riski_necritic,
              sum(v_rabote)           as v_rabote
       from (
              WITH RECURSIVE r AS (
                SELECT targ.id, targ.parent_id, targ.name
                FROM targets targ
                WHERE targ.id = "+ target_id+"

                UNION

                SELECT targ.id, targ.parent_id, targ.name
                FROM targets targ
                       JOIN r
                            ON targ.parent_id = r.id
                )
                select target_id,
                       sum(ispolneno)          as ispolneno,
                       sum(ne_ispolneno)       as ne_ispolneno,
                       sum(est_riski_critic)   as est_riski_critic,
                       sum(est_riski_necritic) as est_riski_necritic,
                       sum(v_rabote)           as v_rabote
                from (
                       select tswp.target_id,
                              case when ispolneno = true then 1 else 0 end as ispolneno,
                              case when ne_ispolneno = true then 1 else 0 end as ne_ispolneno,
                              case when (est_riski = true) and (r.importance = '"+I18n.t(:default_impotance_critical)+"') then 1 else 0 end  as est_riski_critic, "+
                       "      case when (est_riski = true) and (r.importance = '"+I18n.t(:default_impotance_low)+"' or r.importance is null) then 1 else 0 end as est_riski_necritic,
                              case when v_rabote = true then 1 else 0 end as v_rabote
                       from v_target_status_on_work_package tswp
                              inner join types t on tswp.type_id = t.id
                              left join v_risk_problem_stat r on r.work_package_id = tswp.id

                       where year = EXTRACT(YEAR FROM CURRENT_DATE)
                         and t.name = '"+I18n.t(:default_type_milestone)+"'"+
                     ") as s, r
                where s.target_id = r.id
                group by s.target_id
            ) as s
          )

    select t.id, t.name,s.ispolneno,s.ne_ispolneno, s.est_riski_critic, s.est_riski_necritic,s.v_rabote
    from targets t
    left join stat s on s.target_id = t.id
    where t.is_approve = true  and t.id = " + target_id+" and t.project_id = "+@project.id.to_s

    result_sql = ActiveRecord::Base.connection.execute(sql)

    result = result_sql[0]
  end


  def get_month_kt_values
    sql = "with
              plan_kt as (
               select EXTRACT(MONTH FROM wp.due_date) as plan_month, count(wp.id) as plan_kt
               from v_work_package_ispoln_stat wp
               inner join types t on wp.type_id = t.id
               where EXTRACT(year FROM due_date) = EXTRACT(year FROM current_date) and
                     t.name = '"+I18n.t(:default_type_milestone)+"' and wp.project_id=" + @project.id.to_s +
             "  group by EXTRACT(MONTH FROM wp.due_date)
             ),
              fact_kt as (
                 select EXTRACT(MONTH FROM wp.fact_due_date) as fact_month, count(wp.id) as fact_kt
                 from v_work_package_ispoln_stat wp
                         inner join types t on wp.type_id = t.id
                 where EXTRACT(year FROM fact_due_date) = EXTRACT(year FROM current_date) and
                     t.name = '"+I18n.t(:default_type_milestone)+"' and wp.project_id=" + @project.id.to_s +
              "   group by EXTRACT(MONTH FROM wp.fact_due_date)
              ),
              not_time_kt as (
                 select EXTRACT(MONTH FROM wp.fact_due_date) as fact_month, count(wp.id) as fact_kt
                 from v_work_package_ispoln_stat wp
                         inner join types t on wp.type_id = t.id
                 where EXTRACT(year FROM fact_due_date) = EXTRACT(year FROM current_date) and
                       days_to_due < 0 and t.name = '"+I18n.t(:default_type_milestone)+"' and wp.project_id=" + @project.id.to_s +
              "    group by EXTRACT(MONTH FROM wp.fact_due_date)
              ),
              riski_kt as (
                 select EXTRACT(MONTH FROM wp.due_date) as plan_month, count(wp.id) as riski
                 from v_work_package_ispoln_stat wp
                         inner join types t on wp.type_id = t.id
                 where EXTRACT(year FROM due_date) = EXTRACT(year FROM current_date) and
                       est_riski = true and t.name = '"+I18n.t(:default_type_milestone)+"' and wp.project_id=" + @project.id.to_s +
              "   group by EXTRACT(MONTH FROM wp.due_date)
              )


             select p.plan_month as month, p.plan_kt as plan_value, coalesce(f.fact_kt, 0) as value,
                    coalesce(nt.fact_kt, 0) as not_time, coalesce(r.riski, 0) as riski
             from plan_kt p
             left outer join   fact_kt f on f.fact_month = p.plan_month
             left outer join   not_time_kt nt on nt.fact_month = p.plan_month
             left outer join   riski_kt r on r.plan_month = p.plan_month"

    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []

    result.each do |row|
      result_array[index] = row
      index += 1
    end

    result_array
  end

  def get_v_risk_problem_stat(risk_id)
    sql = " select vr.type, e.name
            from v_risk_problem_stat vr
            left outer join enumerations e on e.id = vr.importance_id
            where vr.problem_id = " + risk_id

    result_sql= ActiveRecord::Base.connection.execute(sql)
    result = 0
    if result_sql[0]["type"].to_s == "solved_risk"
      result = 1
    elsif result_sql[0]["type"].to_s == "created_risk" && result_sql[0]["name"].to_s == I18n.t(:default_impotance_low)
      result = 2
    elsif result_sql[0]["type"].to_s == "created_risk" && result_sql[0]["name"].to_s == I18n.t(:default_impotance_critical)
      result = 3
    end

    result
  end

  def get_v_risk_problem_stat_critic
    sql = " select count(vr.id) as count_risk
            from v_risk_problem_stat vr
            inner join enumerations e on e.id = vr.importance_id "+
          " where  e.name='"+I18n.t(:default_impotance_critical)+"' and vr.project_id=" + @project.id.to_s

    result_sql= ActiveRecord::Base.connection.execute(sql)
    result = result_sql[0]["count_risk"].to_i > 0 ? 1 : 0
    result
  end

  def get_v_risk_problem_stat_low
    sql = " select count(vr.id)  as count_risk
            from v_risk_problem_stat vr
            inner join enumerations e on e.id = vr.importance_id "+
      " where  e.name='"+I18n.t(:default_impotance_low)+"' and vr.project_id=" + @project.id.to_s

    result_sql= ActiveRecord::Base.connection.execute(sql)
    result = result_sql[0]["count_risk"].to_i > 0 ? 1 : 0
    result
  end


  def get_v_risk_problem_stat_solved
    sql = " select type
            from v_risk_problem_stat
            where  project_id=" + @project.id.to_s

    result_sql= ActiveRecord::Base.connection.execute(sql)

    result_array = []
    is_risk = 0
    index = 0;
    result_sql.each do |row|
      if row["type"].to_s != 'solved_risk'
        is_risk = 1
      end
      index += 1
    end

    result = is_risk == 0 && index > 0  ? 1 : 0
    result
  end


  def get_v_risk_problem_stat_is_empty
    sql = " select count(vr.id) as count_risk
            from v_risk_problem_stat vr
            where  vr.project_id=" + @project.id.to_s

    result_sql= ActiveRecord::Base.connection.execute(sql)
    result = rresult_sql[0]["count_risk"].to_i == 0 ? 1 : 0
    result
  end



  def get_target_graph_values(target_id)
    sql = " select t.id, t.name, t.basic_value,
            v.target_quarter1_value,v.target_quarter2_value,
            v.target_quarter3_value,v.target_quarter3_value,
            v.fact_quarter1_value,v.fact_quarter2_value,
            v.fact_quarter3_value,v.fact_quarter3_value
            FROM targets t
            inner join v_plan_fact_quarterly_target_values v  on v.target_id=t.id
            where v.year = EXTRACT(year FROM current_date) and t.id = "+target_id

    result_sql = ActiveRecord::Base.connection.execute(sql)
    result = result_sql[0]
  end




  def get_budjet_by_cost_type
    sql = "select t.id, t.name,t.national_project_goal, m.cost_type_id, sum(m.passport_units) as passport_units,
                   sum(m.consolidate_units) as consolidate_units, sum(m.budget) as limit_units,
                   sum(ce.recorded_liability) as recorded_liability,sum(ce.costs) as kassa
           FROM targets t
           left join cost_objects co on co.target_id = t.id
           left join material_budget_items m on m.cost_object_id = co.id
           left join work_packages wp on wp.cost_object_id = co.id
           left join cost_entries ce on wp.id = ce.work_package_id
           left join cost_types ct on ct.id = m.cost_type_id
           inner join enumerations e on e.id = t.type_id
           where t.project_id = " + @project.id.to_s+" and e.name = '"+I18n.t(:default_result)+"'
           group by t.id, t.name,t.national_project_goal, m.cost_type_id
           order by t.id, m.cost_type_id"


    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []
    result.each do |row|
      result_array[index] = row
      index += 1
    end
    result_array
  end


  def destroy
    redirect_to action: 'index'
    nil
  end

  protected

  def show_local_breadcrumb
    true
  end

  private

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def verify_reportsProgressProject_module_activated
    render_403 if @project && !@project.module_enabled?('report_progress_project')
  end


end
