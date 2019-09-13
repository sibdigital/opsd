require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
class ReportPassportController < ApplicationController

  include Downloadable

  default_search_scope :report_passport

  before_action :verify_reportPassport_module_activated

  def index_params
    params.require(:report_id)
  end

  def index

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

    if  params[:report_id] == 'report_passport'
      generate_passport_report_out
      send_to_user filepath: @ready_passport_report_path
    end


  end

  def generate_passport_report_out
    template_path = File.absolute_path('.') +'/'+'app/reports/templates/passport.xlsx'
    @workbook = RubyXL::Parser.parse(template_path)
    @workbook.calc_pr.full_calc_on_load = true

    generate_title_sheet
    #generate_key_risk_sheet
    #generate_targets_sheet
    #generate_status_execution_budgets_sheet
    #generate_status_achievement_sheet
    #generate_dynamic_achievement_kt_sheet

    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end


    @ready_passport_report_path = dir_path + '/passport_out.xlsx'
    @workbook.write(@ready_passport_report_path)
  end



  def generate_title_sheet


    @date_today = Date.today.strftime("%d.%m.%Y")
    curatorProject = get_Member(I18n.t(:default_role_project_curator))
    leaderProject = get_Member(I18n.t(:default_role_project_head))
    adminProject = get_Member(I18n.t(:default_role_project_admin))
    start_date = @project.start_date
    due_date = @project.due_date
    period_project = (start_date == nil ? "": start_date.strftime("%d.%m.%Y"))+" - " + (due_date == nil ? "": due_date.strftime("%d.%m.%Y"))
    sheet = @workbook['Основные положения']

    sheet[14][0].change_contents(@project.name)
    sheet[18][1].change_contents(@federal_project == nil ? "" :@federal_project.name)
    sheet[19][1].change_contents(@project.name)
    sheet[19][6].change_contents(period_project)
    sheet[20][1].change_contents(curatorProject)
    sheet[21][1].change_contents(leaderProject)
    sheet[22][1].change_contents(adminProject)

  # default_role_project_admin: Администратор проекта
  # default_role_project_curator: Куратор проекта
  # default_role_project_customer: Заказчик проекта
  # default_role_project_office_manager: Руководитель проектного офиса
  # default_role_project_activity_coordinator: Координатор проектной деятельности
  # default_role_project_office_coordinator: Координатор от проектного офиса
  # default_role_events_responsible: Ответственный за блок мероприятий
  # default_role_project_head: Руководитель проекта
  # default_role_project_office_admin: Администратор проектного офиса


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

  end

  def generate_status_achievement_sheet

    no_devation =  Setting.find_by(name: 'no_devation').value
    small_devation =  Setting.find_by(name: 'small_devation').value

    sheet = @workbook['Статус достижения результатов']

    data_row = 3
    incriment = 0
    status_result = 0
    id_type_result = Enumeration.find_by(name: I18n.t(:default_result)).id
    targets = Target.where(project_id: @project.id, type_id: id_type_result)
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

  end


  def get_Member(role_name)
  userList = User.find_by_sql("  SELECT u.* FROM users u
                                           INNER JOIN members  m ON m.user_id = u.id
                                           INNER JOIN member_roles mr ON  mr.member_id = m.id
                                           INNER JOIN roles r ON  mr.role_id = r.id and r.name ='" +role_name+"' "+
                                 "INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s)

  if userList.empty?
    user = User.new
  else
    user = userList[0]
  end

  if user.patronymic.to_s.empty?
    patronymic = ""
  else  patronymic = user.patronymic
  end

  if user.lastname.to_s.empty?
    lastname = ""
  else  lastname = user.lastname
  end

  if user.firstname.to_s.empty?
    firstname = ""
  else  firstname = user.firstname
  end

  if user.firstname.to_s.empty?
    firstname = ""
  else  firstname = user.firstname
  end

  fio = lastname + " " + firstname + " " + patronymic
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
            where ( e.name = '"+I18n.t(:default_target)+"' or e.name = '"++I18n.t(:default_indicator)+"') and t.project_id = "+ @project.id.to_s


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
            where e.name = '"+I18n.t(:default_result)+"' and t.id = "+target_id +" and t.project_id = "+ @project.id.to_s


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

    sheetDataDiagram[3][4].change_contents(result_fed_budjet[0])
    sheetDataDiagram[4][4].change_contents(result_fed_budjet[1])
    sheetDataDiagram[5][4].change_contents(result_fed_budjet[2])

    sheetDataDiagram[3][9].change_contents(result_reg_budjet[0])
    sheetDataDiagram[4][9].change_contents(result_reg_budjet[1])
    sheetDataDiagram[5][9].change_contents(result_reg_budjet[2])

    sheetDataDiagram[3][14].change_contents(result_other_budjet[0])
    sheetDataDiagram[4][14].change_contents(result_other_budjet[1])
    sheetDataDiagram[5][14].change_contents(result_other_budjet[2])


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
        elsif kt["month"].to_i == 2
          sheetDataDiagram.insert_cell(10, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(10, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 3
          sheetDataDiagram.insert_cell(11, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(11, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 4
          sheetDataDiagram.insert_cell(12, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(12, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 5
          sheetDataDiagram.insert_cell(13, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(13, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 6
          sheetDataDiagram.insert_cell(14, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(14, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 7
          sheetDataDiagram.insert_cell(15, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(15, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 8
          sheetDataDiagram.insert_cell(16, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(16, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 9
          sheetDataDiagram.insert_cell(17, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(17, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 10
          sheetDataDiagram.insert_cell(18, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(18, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 11
          sheetDataDiagram.insert_cell(19, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(19, 3, kt["value"].to_i)
        elsif kt["month"].to_i == 12
          sheetDataDiagram.insert_cell(20, 2, kt["plan_value"].to_i)
          sheetDataDiagram.insert_cell(21, 3, kt["value"].to_i)
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

  def verify_reportPassport_module_activated
    render_403 if @project && !@project.module_enabled?('reports')
  end


end
