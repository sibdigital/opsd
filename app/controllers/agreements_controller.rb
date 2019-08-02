require 'rtf-templater'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
class AgreementsController < ApplicationController
  include RtfTemplater::Generator
  include Downloadable

  default_search_scope :agreements

  before_action :find_optional_project, :verify_agreements_module_activated
  before_action :find_agreement, only: [:edit, :update, :destroy]


  def generate_agreement

    if Setting.find_by(name: 'region_name').nil?
      @region_name = ""
    else
      @region_name = Setting.find_by(name: 'region_name').value
    end

    @absolute_path = File.absolute_path('.') +'/'+'app/reports/templates/agreement.rtf'
    @ready_agreement_path = File.absolute_path('.') +'/'+'public/reports/agreement-out.rtf'

    @region_project = @project.name
    @date_agreement = @agreement.date_agreement.strftime("%d.%m.%Y")
    @number_agreement = @agreement.number_agreement
    @count_days = @agreement.count_days
    @other_liabilities_2141 = @agreement.other_liabilities_2141
    @other_liabilities_2142 = @agreement.other_liabilities_2142
    @other_liabilities_2281 = @agreement.other_liabilities_2281
    @other_liabilities_2282 = @agreement.other_liabilities_2282
    @state_program = @agreement.state_program
    if @agreement.date_end.nil?
      @date_end = ""
      else
      @date_end = @agreement.date_end.strftime("%d.%m.%Y")
    end

    if @federal_project.nil? || @federal_project.leader.nil?
       @leader_federal_project = ""
    else
       @leader_federal_project = @federal_project.leader
    end
    if @federal_project.nil? || @federal_project.leader_position.nil?
      @leader_position_federal_project = ""
    else
      @leader_position_federal_project = @federal_project.leader_position
    end

    @leader_federal_project_position =  @leader_federal_project+", "+@leader_position_federal_project.downcase
    if @federal_project.nil?
      @federal_project_name = ""
    else
      @federal_project_name = @federal_project.name
    end
    if @national_project.nil?
      @national_project_name = ""
    else
      @national_project_name = @national_project.name
    end

    @region_project_name = @project.name

    @userList = User.find_by_sql("  SELECT u.* FROM users u
                                           INNER JOIN members  m ON m.user_id = u.id
                                           INNER JOIN member_roles mr ON  mr.member_id = m.id
                                           INNER JOIN roles r ON  mr.role_id = r.id and r.name = 'Руководитель проекта'
                                           INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s)
    if @userList.empty?
      @user = User.new
     else
      @user = @userList[0]
    end

    if @user.patronymic.to_s.empty?
      @patronymic = ""
    else  @patronymic = @user.patronymic
    end

    if @user.lastname.to_s.empty?
        @lastname = ""
    else  @lastname = @user.lastname
    end

    if @user.firstname.to_s.empty?
      @firstname = ""
    else  @firstname = @user.firstname
    end

    if @user.firstname.to_s.empty?
      @firstname = ""
    else  @firstname = @user.firstname
    end

    @leader_region_project =  @lastname + " "+ @firstname + " " + @patronymic
    if Position.find_by(id: @user.position_id).nil?
      @position = ""
    else
      @position = Position.find_by(id: @user.position_id).name
    end

    @fio_position = @lastname + " "+ @firstname + " " + @patronymic + ", "+ @position.downcase
    File.open @absolute_path do |f|
      content = f.read
      f = File.new(@ready_agreement_path, 'w')
      f << render_rtf(content)
      f.close
    end

    def download
      send_to_user filepath: @ready_agreement_path
    end

  end

  def index
    @agreement = Agreement.find_by(project_id: @project.id)
    if @agreement == nil
      @agreement = Agreement.new
    else
      redirect_to edit_project_agreement_path(id: @agreement.id)
    end

  end

  def edit
    @agreement = Agreement.find(params[:id])
    if @agreement.national_project_id
       @national_project = NationalProject.find(@agreement.national_project_id)
    else
       @national_project = nil
    end
    if @agreement.federal_project_id
       @federal_project = NationalProject.find(@agreement.federal_project_id)
    else
       @federal_project = nil
    end
    if  params[:report_id] == 'agreement'
      generate_agreement
      download
    end

    if  params[:report_id] == 'excel'
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

    @targets = Target.where(project_id: @project.id)

    data_row = 4
    #@targets.each_with_index do |target, i|
    @result_array_targets.each_with_index do |target, i|

    @workPackageTarget = WorkPackageTarget.find_by(work_package_id: target["work_package_id"])
    @prevWorkPackageTarget = WorkPackageTarget.find_by(project_id: @project.id, work_package_id: target["work_package_id"], year: Date.today.year-1, quarter: 4, month: 12, target_id: target["target_id"])


    @targetExecutionValues = TargetExecutionValue.find_by(year: Date.today.year, quarter: 4, target_id: target["target_id"])
    @targetExecutionValues = @targetExecutionValues == nil ? TargetExecutionValue.find_by(year: Date.today.year, quarter: nil , target_id: target["target_id"]) : @targetExecutionValues

    @workPackageTargetValue = target["quarter4"] != "0" ? target["quarter4"] : ( target["quarter3"]!= "0" ? target["quarter3"] : (target["quarter2"] != "0" ? target["quarter2"] : (target["quarter1"] != "0" ? target["quarter1"] : "0")) )

    @procent = '%.2f' %(@targetExecutionValues == nil ? 0 : (@workPackageTargetValue.to_f / @targetExecutionValues.value)*100)

      sheet.insert_cell(data_row + i, 0, i+1)
      sheet.insert_cell(data_row + i, 1, "")
      sheet.insert_cell(data_row + i, 2, @workPackageTarget.work_package.subject)
      sheet.insert_cell(data_row + i, 3, @workPackageTarget.target.measure_unit.short_name)
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
     @budjets = AllBudgetsHelper.cost_by_project @project
     sheet = @workbook['Данные для диаграмм']
     total_budget = @budjets[:total_budget]
     ostatok_budget = @budjets[:ostatok]
     sheet[3][4].change_contents(total_budget)
     sheet[5][4].change_contents(total_budget)
  end


  def new
    @agreement = Agreement.new
  end

  def create
    @agreement = @project.agreements.create(permitted_params.agreement)

    if @agreement.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @agreement.update_attributes(permitted_params.agreement)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_agreements_path()
    else
      render action: 'edit'
    end
  end

  def destroy
    @agreement.destroy
    redirect_to action: 'index'
    nil
  end

  protected

  def find_agreement
    @agreement = @project.agreements.find(params[:id])
  end

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
    render_403 if @project && !@project.module_enabled?('agreements')
  end

end
