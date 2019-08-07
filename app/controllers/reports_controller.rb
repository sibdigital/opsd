require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
class ReportsController < ApplicationController

  include Downloadable

  default_search_scope :reports

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
       sheet.insert_cell(data_row + i, 3, workPackageProblem.risk.description)
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
    puts index
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


  # Функция заполнения значений долей диаграммы
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
