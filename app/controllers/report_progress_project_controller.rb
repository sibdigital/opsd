require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
class ReportProgressProjectController < ApplicationController

  include Downloadable

  default_search_scope :report_progress_project

  before_action :verify_agreements_module_activated


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

    if  params[:report_id] == 'report_progress_project'
      generate_project_progress_report_out
      send_to_user filepath: @ready_project_progress_report_path
    end

  end

  def generate_project_progress_report_out
#        @agreements = Agreement.all
#        render xlsx: "report_excel", template: "agreements/report_excel.xlsx.axlsx"
    @absolute_path = File.absolute_path('.') +'/'+'app/reports/templates/agreement.rtf'
    template_path = File.absolute_path('.') +'/'+'app/reports/templates/project_progress_report.xlsx'
    @workbook = RubyXL::Parser.parse(template_path)
    @workbook.calc_pr.full_calc_on_load = true

    generate_title_sheet
    generate_key_risk_sheet
    generate_targets_sheet
    generate_status_execution_budgets_sheet
    generate_status_achievement_sheet

    @ready_project_progress_report_path = File.absolute_path('.') +'/'+'public/reports/project_progress_report_out.xlsx'
    @workbook.write(@ready_project_progress_report_path)
  end


  def generate_title_sheet

    @leader_federal_project = @federal_project == nil ? "" : (@federal_project.leader == nil ? "" : @federal_project.leader)
    @date_today = Date.today.strftime("%d.%m.%Y")

    sheet = @workbook['Титульный лист']

    sheet[9][3].change_contents(@leader_federal_project)
    sheet[12][3].change_contents(@date_today)
    sheet[22][11].change_contents(@project.name)

    #  0ba53d -зеленый
    #  ff0000 -красный
    #  ffd800 -желтый
    sheet.sheet_data[27][5].change_fill('ff0000')
    sheet.sheet_data[27][9].change_fill('ffd800')
    sheet.sheet_data[27][13].change_fill('0ba53d')
    sheet.sheet_data[27][17].change_fill('0ba53d')
    sheet.sheet_data[27][21].change_fill('ffd800')

  end

  def generate_key_risk_sheet
    sheet = @workbook['Ключевые риски']
    @workPackageProblems = WorkPackageProblem.where(project_id: @project.id)

    data_row = 3
    @workPackageProblems.each_with_index do |workPackageProblem, i|

       sheet.insert_cell(data_row + i, 0, i+1)
       sheet.insert_cell(data_row + i, 1, "")
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
  end

  def generate_targets_sheet

    sheet = @workbook['Сведения о значениях целей']

    get_value_targets

    data_row = 4

    @result_array_targets.each_with_index do |target, i|

    @workPackageTarget = WorkPackageTarget.find_by(work_package_id: target["work_package_id"])
    @prevWorkPackageTarget = WorkPackageTarget.find_by(project_id: @project.id, work_package_id: target["work_package_id"], year: Date.today.year-1, quarter: 4, month: 12, target_id: target["target_id"])


    @targetExecutionValues = TargetExecutionValue.find_by(year: Date.today.year, quarter: 4, target_id: target["target_id"])
    @targetExecutionValues = @targetExecutionValues == nil ? TargetExecutionValue.find_by(year: Date.today.year, quarter: nil , target_id: target["target_id"]) : @targetExecutionValues

    @workPackageTargetValue = target["quarter4"] != "0" ? target["quarter4"] : ( target["quarter3"]!= "0" ? target["quarter3"] : (target["quarter2"] != "0" ? target["quarter2"] : (target["quarter1"] != "0" ? target["quarter1"] : "0")) )

    @procent = '%.2f' %(@targetExecutionValues == nil ? 0 : (@workPackageTargetValue.to_f / @targetExecutionValues.value)*100)

    measure_unit = @workPackageTarget.target.measure_unit == nil ? "" : @workPackageTarget.target.measure_unit.short_name

      sheet.insert_cell(data_row + i, 0, i+1)
      sheet.insert_cell(data_row + i, 1, "")
      sheet.insert_cell(data_row + i, 2, @workPackageTarget.work_package.subject)
      sheet.insert_cell(data_row + i, 3, measure_unit)
      sheet.insert_cell(data_row + i, 4, @prevWorkPackageTarget == nil ? "" : @prevWorkPackageTarget.value)
      sheet.insert_cell(data_row + i, 5, target["quarter1"])
      sheet.insert_cell(data_row + i, 6, target["quarter2"])
      sheet.insert_cell(data_row + i, 7, target["quarter3"])
      sheet.insert_cell(data_row + i, 8, target["quarter4"])
      sheet.insert_cell(data_row + i, 9, @targetExecutionValues == nil ? "" : @targetExecutionValues.value)
      sheet.insert_cell(data_row + i, 10, @procent)
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

  end

  def generate_status_achievement_sheet
    sheet = @workbook['Статус достижения результатов']
    get_status_achievement
    data_row = 3
    incriment = 0
    @result_array_status_achievement.each_with_index do |status, i|
      sheet.insert_cell(data_row + i + incriment, 0, i+1)
      sheet.insert_cell(data_row + i + incriment, 1, "")
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
      #sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"])
      #sheet.insert_cell(data_row + i + incriment, 5, status["ne_ispolneno"])
      #sheet.insert_cell(data_row + i + incriment, 6, status["est_riski"])
      #sheet.insert_cell(data_row + i + incriment, 7, status["v_rabote"])
      sheet.insert_cell(data_row + i + incriment, 8, "")

      #  0ba53d -зеленый
      #  ff0000 -красный
      #  ffd800 -желтый
      #  d7d7d7 - серый
      #  90ee90 - светло-зеленный
      #{ начало вариантов для 1 цвета
      if  status["ispolneno"].nil?
        sheet.sheet_data[data_row + i + incriment][4].change_fill('d7d7d7')
        sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 7)

      elsif
        (status["ispolneno"]+status["v_rabote"]) > 0 && status["ne_ispolneno"] == 0 && status["est_riski_critic"] == 0 && status["est_riski_necritic"] == 0
        sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"]+status["v_rabote"])
        sheet.sheet_data[data_row + i + incriment][4].change_fill('0ba53d')
        sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 7)

      elsif
          (status["ne_ispolneno"] + status["est_riski_critic"]) > 0 && status["ispolneno"] == 0 && status["est_riski_necritic"] == 0 && status["v_rabote"] == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ne_ispolneno"]+ status["est_riski_critic"])
          sheet.sheet_data[data_row + i + incriment][4].change_fill('ff0000')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 7)

      elsif
          status["est_riski_necritic"] > 0 && status["ispolneno"] == 0 && status["ne_ispolneno"] == 0 && status["v_rabote"] == 0 && status["est_riski_critic"] == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["est_riski_necritic"])
          sheet.sheet_data[data_row + i + incriment][4].change_fill('ffd800')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 7)
        #} конец вариантов для 1 цвета
        # { начало вариантов для 2 цветов
      elsif
          (status["ispolneno"]+status["v_rabote"])  > 0 && (status["ne_ispolneno"]+status["est_riski_critic"]) > 0 && status["est_riski_necritic"] == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"]+status["v_rabote"] == 0)
          sheet.sheet_data[data_row + i + incriment][4].change_fill('0ba53d')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 5)

          sheet.insert_cell(data_row + i + incriment, 6, status["ne_ispolneno"]+status["est_riski_critic"])
          sheet.sheet_data[data_row + i + incriment][6].change_fill('ff0000')
          sheet.merge_cells(data_row + i + incriment, 6, data_row + i + incriment, 7)
      elsif
          (status["ispolneno"] + status["v_rabote"]) > 0 && status["ne_ispolneno"] == 0 && status["est_riski_necritic"] > 0 && status["est_riski_critic"] == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"]+ status["v_rabote"])
          sheet.sheet_data[data_row + i + incriment][4].change_fill('0ba53d')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 5)

          sheet.insert_cell(data_row + i + incriment, 6, status["est_riski_necritic"])
          sheet.sheet_data[data_row + i + incriment][6].change_fill('ffd800')
          sheet.merge_cells(data_row + i + incriment, 6, data_row + i + incriment, 7)
      elsif
          status["ispolneno"] == 0 && (status["ne_ispolneno"]+status["est_riski_critic"]) > 0 && status["est_riski_necritic"] > 0 && status["v_rabote"] == 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ne_ispolneno"]+status["est_riski_critic"])
          sheet.sheet_data[data_row + i + incriment][4].change_fill('ff0000')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 5)

          sheet.insert_cell(data_row + i + incriment, 6, status["est_riski_necritic"])
          sheet.sheet_data[data_row + i + incriment][6].change_fill('ffd800')
          sheet.merge_cells(data_row + i + incriment, 6, data_row + i + incriment, 7)
        #} конец вариантов для 2 цветов
        # { начало вариантов для 3 цветов
      elsif
          (status["ispolneno"]+status["v_rabote"]) > 0 && (status["ne_ispolneno"]+status["est_riski_critic"]) > 0 && status["est_riski_necritic"] > 0
          sheet.insert_cell(data_row + i + incriment, 4, status["ispolneno"])
          sheet.sheet_data[data_row + i + incriment][4].change_fill('0ba53d')
          sheet.merge_cells(data_row + i + incriment, 4, data_row + i + incriment, 5)

          sheet.insert_cell(data_row + i + incriment, 6, status["ne_ispolneno"]+status["est_riski_critic"])
          sheet.sheet_data[data_row + i + incriment][6].change_fill('ff0000')
          sheet.insert_cell(data_row + i + incriment, 7, status["est_riski_necritic"])
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


  end

  def get_value_targets

    sql = "with slice as (select project_id, target_id, work_package_id, year, quarter, max(month) as month
               from work_package_targets as wpt
                          where year = extract(year from current_date) and project_id = "+@project.id.to_s+
          "               group by project_id, target_id, work_package_id, year, quarter
          ),
               slice_values as (
                 select s.*, value, plan_value
                 from slice as s
                        inner join work_package_targets as w
                                   on (s.project_id, s.target_id, s.work_package_id, s.year, s.quarter, s.month) =
                                      (w.project_id, w.target_id, w.work_package_id, w.year, w.quarter, w.month)
               )
          select project_id, work_package_id, target_id, year, plan_value,  value as quarter1, 0 as quarter2, 0 as quarter3, 0 as quarter4
          FROM slice_values as wpt
          where quarter = 1
          union all
          select project_id, work_package_id, target_id, year, plan_value, 0 as quarter1, value as quarter2, 0 as quarter3, 0 as quarter4
          FROM slice_values as wpt
          where quarter = 2
          union all
          select project_id, work_package_id, target_id, year, plan_value, 0 as quarter1, 0 as quarter2, value as quarter3, 0 as quarter4
          FROM slice_values as wpt
          where quarter = 3
          union all
          select project_id, work_package_id, target_id, year, plan_value, 0 as quarter1, 0 as quarter2, 0 as quarter3, value as quarter4
          FROM slice_values as wpt
          where quarter = 4"

    result = ActiveRecord::Base.connection.execute(sql)

    @result_array_targets = []
    index = 0
    result.each do |row|
      @result_array_targets[index] = row

      index += 1
    end
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
     #total_budget = @budjets[:total_budget]
     #ostatok_budget = @budjets[:ostatok]
    # sheetDataDiagram[3][4].change_contents(total_budget)
    # sheetDataDiagram[5][4].change_contents(total_budget)


    sheetDataDiagram[3][4].change_contents(result_fed_budjet[0])
    sheetDataDiagram[4][4].change_contents(result_fed_budjet[1])
    sheetDataDiagram[5][4].change_contents(result_fed_budjet[2])

    sheetDataDiagram[3][9].change_contents(result_reg_budjet[0])
    sheetDataDiagram[4][9].change_contents(result_reg_budjet[1])
    sheetDataDiagram[5][9].change_contents(result_reg_budjet[2])

    sheetDataDiagram[3][14].change_contents(result_other_budjet[0])
    sheetDataDiagram[4][14].change_contents(result_other_budjet[1])
    sheetDataDiagram[5][14].change_contents(result_other_budjet[2])

  end


   def fed_budget_data
    cost_objects = CostObject.where(project_id: @project.id)
    total_budget = BigDecimal("0")
    spent = BigDecimal("0")

    cost_objects.each do |cost_object|
      total_budget += cost_object.budget
      spent += cost_object.spent
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
      total_budget += cost_object.budget
      labor_budget += cost_object.labor_budget
      spent += cost_object.spent
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
      total_budget += cost_object.budget
      material_budget += cost_object.labor_budget
      spent += cost_object.spent
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


  def get_status_achievement


    sql = "with
    stat as (
              select target_id,
                  sum(ispolneno)    as ispolneno,
                  sum(ne_ispolneno) as ne_ispolneno,
                  sum(est_riski_critic)    as est_riski_critic,
                  sum(est_riski_necritic)    as est_riski_necritic,
    from (
           select tswp.target_id,
                  case when ispolneno = true then 1 else 0 end    as ispolneno,
                  case when ne_ispolneno = true then 1 else 0 end as ne_ispolneno,
                  case when (est_riski = true) and (r.importance='Критичная') then 1 else 0 end as est_riski_critic,
                  case when (est_riski = true) and (r.importance='Незначительная' or r.importance is null) then 1 else 0 end as est_riski_necritic,
                  case when v_rabote = true then 1 else 0 end     as v_rabote
    from v_target_status_on_work_package tswp
    inner join types t on tswp.type_id = t.id
    left join v_risk_problem_stat r on r.work_package_id = tswp.id
    where year = EXTRACT(YEAR FROM CURRENT_DATE) and t.name='"+I18n.t(:default_type_milestone)+"' "+
    ") as s
    group by target_id
    )
    select t.name,s.ispolneno,s.ne_ispolneno, s.est_riski_critic, s.est_riski_necritic,s.v_rabote
    from targets t
    left join stat s on s.target_id = t.id
    where t.project_id="+@project.id.to_s


    result = ActiveRecord::Base.connection.execute(sql)

    @result_array_status_achievement = []
    index = 0
    result.each do |row|
      @result_array_status_achievement[index] = row

      index += 1
    end
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

  def verify_agreements_module_activated
    render_403 if @project && !@project.module_enabled?('reports')
  end


end
