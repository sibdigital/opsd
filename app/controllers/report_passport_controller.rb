require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
class ReportPassportController < ApplicationController

  include Downloadable

  default_search_scope :report_passport

  before_action :find_optional_project, :verify_reportPassport_module_activated

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
    generate_target_indicators_sheet
    generate_target_results_sheet
    generate_budget_sheet
    generate_members_sheet
    generate_additonal_info
    generate_plan_sheet
    generate_method_calc_sheet

    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end


    @ready_passport_report_path = dir_path + '/passport_out.xlsx'
    @workbook.write(@ready_passport_report_path)
  end



  def generate_title_sheet

    @date_today = Date.today.strftime("%d.%m.%Y")
    @curatorsProject = get_member_by_role(I18n.t(:default_role_project_curator))
    @leadersProject = get_member_by_role(I18n.t(:default_role_project_head))
    @adminsProject = get_member_by_role(I18n.t(:default_role_project_admin))

    @str_set_curators = ""
    index = 0
    @curatorsProject.each do |user|
      if index  == 0
        @str_set_curators += user.name(:fullname)

      else
        @str_set_curators += ", "+user.name(:fullname)
      end
      index += 1
    end

    @str_set_leaders = ""
    index = 0
    @leadersProject.each do |user|
      if index  == 0
        @str_set_leaders += user.name(:fullname)
      else
        @str_set_leaders += ", "+user.name(:fullname)
      end
      index += 1
    end

    @str_set_admins = ""
    index = 0
    @adminsProject.each do |user|
      if index  == 0
        @str_set_admins += user.name(:fullname)
      else
        @str_set_admins += ", "+user.name(:fullname)
      end
      index += 1
    end


    start_date = @project.start_date
    due_date = @project.due_date
    period_project = (start_date == nil ? "": start_date.strftime("%d.%m.%Y"))+" - " + (due_date == nil ? "": due_date.strftime("%d.%m.%Y"))
    sheet = @workbook['Основные положения']

    sheet[14][0].change_contents(@project.name)
    sheet[18][1].change_contents(@federal_project == nil ? "" :@federal_project.name)
    sheet[19][1].change_contents(@project.name)
    sheet[19][6].change_contents(period_project)
    sheet[20][1].change_contents(@str_set_curators)
    sheet[21][1].change_contents(@str_set_leaders)
    sheet[22][1].change_contents(@str_set_admins)
    sheet[23][1].change_contents(@project.government_program)

  end



  def generate_target_indicators_sheet

      sheet = @workbook['Цель и показатели']
      sheet[1][0].change_contents(get_name_target.nil? ? "": get_name_target)

      count_year = difference_in_completed_years(@project.start_date, @project.due_date)

      sheet.insert_cell(1,7+count_year, "")
      sheet.merge_cells(1, 0, 1, 7+count_year)
      sheet.sheet_data[1][7+count_year].change_border(:right, 'thin')

      sheet.insert_cell(2,7+count_year, "")
      sheet.merge_cells(2, 7, 2, 7+count_year)
      sheet.sheet_data[2][7+count_year].change_border(:right, 'thin')

      for i in 0..count_year
        sheet.insert_cell(3, 7+i, @project.start_date.year+i)
        sheet.insert_cell(4, 7+i, "")
        sheet.merge_cells(3, 7+i, 4, 7+i)

        sheet.insert_cell(1, 7+i, "")
        sheet.sheet_data[1][7+i].change_border(:top, 'thin')
        sheet.sheet_data[1][7+i].change_border(:left, 'thin')
        sheet.sheet_data[1][7+i].change_border(:right, 'thin')
        sheet.sheet_data[1][7+i].change_border(:bottom, 'thin')


        sheet.sheet_data[3][7+i].change_border(:top, 'thin')
        sheet.sheet_data[3][7+i].change_border(:left, 'thin')
        sheet.sheet_data[3][7+i].change_border(:right, 'thin')
        sheet.sheet_data[3][7+i].change_border(:bottom, 'thin')

        sheet.sheet_data[4][7+i].change_border(:top, 'thin')
        sheet.sheet_data[4][7+i].change_border(:left, 'thin')
        sheet.sheet_data[4][7+i].change_border(:right, 'thin')
        sheet.sheet_data[4][7+i].change_border(:bottom, 'thin')
      end

#      sheet.merge_cells(5, 0, 5, 7+count_year)

#      sheet.insert_cell(5, 0, "")
#      sheet.sheet_data[5][0].change_border(:left, 'thin')

#      sheet.insert_cell(5, 7+count_year, "")
#      sheet.sheet_data[5][7+count_year].change_border(:right, 'thin')


      id_type_indicator = Enumeration.find_by(name: I18n.t(:default_indicator)).id
      targets = Target.where(project_id: @project.id, type_id: id_type_indicator)

      targets.each_with_index do |target, i|
        sheet.insert_cell(5+i, 0, (i+1).to_s)
        sheet.insert_cell(5+i, 1, target.name)
        cell = sheet[5+i][1]
        cell.change_text_wrap(true)

        type_target = target.is_additional == true ? "дополнительный" : "основной"
        sheet.insert_cell(5+i, 2, type_target)
        sheet.sheet_data[5+i][2].change_horizontal_alignment('center')
        sheet.sheet_data[5+i][2].change_vertical_alignment('center')

        sheet.insert_cell(5+i, 3, target.basic_value)
        sheet.insert_cell(5+i, 4, "")
        sheet.merge_cells(5+i, 3, 5+i, 4)
        sheet.sheet_data[5+i][3].change_horizontal_alignment('center')
        sheet.sheet_data[5+i][3].change_vertical_alignment('center')

        #basic_date = target.basic_date.nil? ? "" : target.basic_date.strftime("%d.%m.%Y")
        basic_date = target.created_at.nil? ? "" : target.created_at.strftime("%d.%m.%Y")
        sheet.insert_cell(5+i, 5, basic_date)
        sheet.insert_cell(5+i, 6, "")
        sheet.merge_cells(5+i, 5, 5+i, 6)
        sheet.sheet_data[5+i][5].change_horizontal_alignment('center')
        sheet.sheet_data[5+i][5].change_vertical_alignment('center')

        sheet.sheet_data[5+i][0].change_border(:top, 'thin')
        sheet.sheet_data[5+i][0].change_border(:left, 'thin')
        sheet.sheet_data[5+i][0].change_border(:right, 'thin')
        sheet.sheet_data[5+i][0].change_border(:bottom, 'thin')

        sheet.sheet_data[5+i][1].change_border(:top, 'thin')
        sheet.sheet_data[5+i][1].change_border(:left, 'thin')
        sheet.sheet_data[5+i][1].change_border(:right, 'thin')
        sheet.sheet_data[5+i][1].change_border(:bottom, 'thin')

        sheet.sheet_data[5+i][2].change_border(:top, 'thin')
        sheet.sheet_data[5+i][2].change_border(:left, 'thin')
        sheet.sheet_data[5+i][2].change_border(:right, 'thin')
        sheet.sheet_data[5+i][2].change_border(:bottom, 'thin')

        sheet.sheet_data[5+i][3].change_border(:top, 'thin')
        sheet.sheet_data[5+i][3].change_border(:left, 'thin')
        sheet.sheet_data[5+i][3].change_border(:right, 'thin')
        sheet.sheet_data[5+i][3].change_border(:bottom, 'thin')

        sheet.sheet_data[5+i][4].change_border(:top, 'thin')
        sheet.sheet_data[5+i][4].change_border(:left, 'thin')
        sheet.sheet_data[5+i][4].change_border(:right, 'thin')
        sheet.sheet_data[5+i][4].change_border(:bottom, 'thin')

        sheet.sheet_data[5+i][5].change_border(:top, 'thin')
        sheet.sheet_data[5+i][5].change_border(:left, 'thin')
        sheet.sheet_data[5+i][5].change_border(:right, 'thin')
        sheet.sheet_data[5+i][5].change_border(:bottom, 'thin')

        sheet.sheet_data[5+i][6].change_border(:top, 'thin')
        sheet.sheet_data[5+i][6].change_border(:left, 'thin')
        sheet.sheet_data[5+i][6].change_border(:right, 'thin')
        sheet.sheet_data[5+i][6].change_border(:bottom, 'thin')

        for j in 0..count_year
          targetValue = PlanFactYearlyTargetValue.find_by(target_id: target.id, year: @project.start_date.year+j)
          target_plan_year_value = targetValue.nil? ? "" : targetValue.target_plan_year_value
          sheet.insert_cell(5+i, 7+j, target_plan_year_value)
          sheet.sheet_data[5+i][7+j].change_border(:top, 'thin')
          sheet.sheet_data[5+i][7+j].change_border(:left, 'thin')
          sheet.sheet_data[5+i][7+j].change_border(:right, 'thin')
          sheet.sheet_data[5+i][7+j].change_border(:bottom, 'thin')
        end
      end

  end

 def generate_target_results_sheet
   sheet = @workbook['Результаты']
   result_str = sheet[3][1].value
   id_type_result = Enumeration.find_by(name: I18n.t(:default_result)).id
   targets = Target.where(project_id: @project.id, type_id: id_type_result, is_approve: true)
   national_project_goal = ""
   targets.each do |target|
     if  target.national_project_goal == nil
       next
     end
     national_project_goal = target.national_project_goal == nil ? " " : target.national_project_goal

     national_project_result = target.national_project_result == nil ? " " : target.national_project_result
     national_project_charact = target.national_project_charact == nil ? " " : target.national_project_charact
     result_due_date = target.result_due_date == nil ? " " : target.result_due_date.strftime("%d.%m.%Y")
     result_str["#"] = national_project_result
     result_str["$"] = national_project_charact
     result_str["%"] = result_due_date
     sheet[3][1].change_contents(result_str)
     break
   end

    result_str["#"] = " "
    result_str["$"] = " "
    result_str["%"] = " "
    sheet[3][1].change_contents(result_str)

   sheet[2][0].change_contents(national_project_goal)

   get_result_target_end_date.each_with_index do |result_target, i|
     punkt = "1."+(i+1).to_s+"."
     sheet.insert_cell(6+i, 0, punkt)
     name = result_target["name"]
     sheet.insert_cell(6+i, 1, name)
     cell = sheet[6+i][1]
     cell.change_text_wrap(true)
     sheet.sheet_data[6+i][1].change_vertical_alignment('center')



     date_end_result=""
     if result_target["quarter"] == "" && result_target["year"] == ""
       date_end_result = ""
     elsif result_target["quarter"] == ""
       date_end_result = "31.12."+result_target["year"]
     elsif result_target["quarter"] == "1"
       date_end_result = "31.03."+result_target["year"]
     elsif result_target["quarter"] == "2"
       date_end_result = "30.06."+result_target["year"]
     elsif result_target["quarter"] == "3"
       date_end_result = "30.09."+result_target["year"]
     elsif result_target["quarter"] == "4"
       date_end_result = "31.12."+result_target["year"]
     end

     if result_target["result_due_date"] == nil || result_target["result_due_date"] == ""
      sheet.insert_cell(6+i, 2, date_end_result)
     else
      sheet.insert_cell(6+i, 2, result_target["result_due_date"].to_date.strftime("%d.%m.%Y"))
     end

     cell = sheet[6+i][2]
     cell.change_text_wrap(true)
     sheet.sheet_data[6+i][2].change_horizontal_alignment('center')
     sheet.sheet_data[6+i][2].change_vertical_alignment('center')

     sheet.insert_cell(6+i, 3, result_target["national_project_charact"])

     sheet.sheet_data[6+i][0].change_border(:top, 'thin')
     sheet.sheet_data[6+i][0].change_border(:left, 'thin')
     sheet.sheet_data[6+i][0].change_border(:right, 'thin')
     sheet.sheet_data[6+i][0].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][1].change_border(:top, 'thin')
     sheet.sheet_data[6+i][1].change_border(:left, 'thin')
     sheet.sheet_data[6+i][1].change_border(:right, 'thin')
     sheet.sheet_data[6+i][1].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][2].change_border(:top, 'thin')
     sheet.sheet_data[6+i][2].change_border(:left, 'thin')
     sheet.sheet_data[6+i][2].change_border(:right, 'thin')
     sheet.sheet_data[6+i][2].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][3].change_border(:top, 'thin')
     sheet.sheet_data[6+i][3].change_border(:left, 'thin')
     sheet.sheet_data[6+i][3].change_border(:right, 'thin')
     sheet.sheet_data[6+i][3].change_border(:bottom, 'thin')

   end
 end

  def generate_budget_sheet
    sheet = @workbook['Финансовое обеспечение']
    count_year = difference_in_completed_years(@project.start_date, @project.due_date)
    sheet.merge_cells(1, 2, 1, 2+count_year)

    # вывод в шапке таблицы наименование годов
    for i in 0..count_year
      sheet.insert_cell(0, 2+i,"")
      sheet.insert_cell(1, 2+i, "Объем финансового обеспечения по годам реализации (млн. рублей)")
      cell = sheet[1][2+i]
      cell.change_text_wrap(true)
      sheet.sheet_data[1][2+i].change_horizontal_alignment('center')
      sheet.sheet_data[1][2+i].change_vertical_alignment('center')

      sheet.insert_cell(2, 2+i, @project.start_date.year+i)
      sheet.sheet_data[2][2+i].change_horizontal_alignment('center')
      sheet.sheet_data[2][2+i].change_vertical_alignment('center')

      sheet.sheet_data[1][2+i].change_border(:top, 'thin')
      sheet.sheet_data[1][2+i].change_border(:left, 'thin')
      sheet.sheet_data[1][2+i].change_border(:right, 'thin')
      sheet.sheet_data[1][2+i].change_border(:bottom, 'thin')

      sheet.sheet_data[2][2+i].change_border(:top, 'thin')
      sheet.sheet_data[2][2+i].change_border(:left, 'thin')
      sheet.sheet_data[2][2+i].change_border(:right, 'thin')
      sheet.sheet_data[2][2+i].change_border(:bottom, 'thin')

      sheet.insert_cell(3, 2+i, "")

    end
    sheet.insert_cell(0, 3+count_year, "")
    sheet.merge_cells(0, 0, 0, 3+count_year)
    sheet.sheet_data[0][ 0].change_horizontal_alignment('center')
    sheet.sheet_data[0][ 0].change_vertical_alignment('center')

    sheet.insert_cell(1, 3+count_year, "Всего (млн. рублей)")
    cell = sheet[1][3+count_year]
    cell.change_text_wrap(true)

    sheet.insert_cell(2, 3+count_year, "")
    sheet.merge_cells(1, 3+count_year, 2, 3+count_year)

    sheet.insert_cell(3, 3+count_year, "")
    sheet.sheet_data[3][3+count_year].change_border(:right, 'thin')
    sheet.merge_cells(3, 1, 3, 3+count_year)


    sheet.sheet_data[1][ 3+count_year].change_horizontal_alignment('center')
    sheet.sheet_data[1][ 3+count_year].change_vertical_alignment('center')

    sheet.sheet_data[1][3+count_year].change_border(:top, 'thin')
    sheet.sheet_data[1][3+count_year].change_border(:left, 'thin')
    sheet.sheet_data[1][3+count_year].change_border(:right, 'thin')
    sheet.sheet_data[1][3+count_year].change_border(:bottom, 'thin')

    sheet.sheet_data[2][3+count_year].change_border(:top, 'thin')
    sheet.sheet_data[2][3+count_year].change_border(:left, 'thin')
    sheet.sheet_data[2][3+count_year].change_border(:right, 'thin')
    sheet.sheet_data[2][3+count_year].change_border(:bottom, 'thin')

    budget_array = get_budjet_by_cost_type_and_year

    id_type_result = Enumeration.find_by(name: I18n.t(:default_result)).id
    targets = Target.where(project_id: @project.id, type_id: id_type_result, is_approve: true)


    if budget_array.count > 0
        sheet[3][1].change_contents(budget_array[0]["national_project_result"])

        cell = sheet[3][1]
        cell.change_text_wrap(true)
        sheet.sheet_data[3][1].change_horizontal_alignment('center')
        sheet.sheet_data[3][1].change_vertical_alignment('center')
    end

    cost_types = CostType.all
    id_target = 0
    count_target= 0
    m = 0
    array = Array.new(cost_types.count) {Array.new (count_year)}
    targets.each_with_index do |target, i|
      if id_target != target["id"].to_i
        count_target += 1
      end
      count_cost_type = 1
      mapYearTarget = {}
      mapCostTypeTarget = {}
      cost_types.each_with_index do |cost_type, j|
        punkt = "1." + count_target.to_s + "." + count_cost_type.to_s + "."

        sheet.insert_cell(5+j+m, 0, punkt)
        sheet.sheet_data[5+j+m][0].change_horizontal_alignment('center')
        sheet.sheet_data[5+j+m][0].change_vertical_alignment('center')

        sheet.sheet_data[5+j+m][0].change_border(:top, 'thin')
        sheet.sheet_data[5+j+m][0].change_border(:left, 'thin')
        sheet.sheet_data[5+j+m][0].change_border(:right, 'thin')
        sheet.sheet_data[5+j+m][0].change_border(:bottom, 'thin')

        sheet.insert_cell(5+j+m, 1, cost_type.name)

        sheet.sheet_data[5+j+m][1].change_vertical_alignment('center')

        sheet.sheet_data[5+j+m][1].change_border(:top, 'thin')
        sheet.sheet_data[5+j+m][1].change_border(:left, 'thin')
        sheet.sheet_data[5+j+m][1].change_border(:right, 'thin')
        sheet.sheet_data[5+j+m][1].change_border(:bottom, 'thin')
        cell = sheet[5+j+m][1]
        cell.change_text_wrap(true)


        for k in 0..count_year
          value = 0
          budget_array.each_with_index do |budget_year, l|

             if (budget_year["plan_year"].to_i == @project.start_date.year+k) &&
                (budget_year["cost_type_id"].to_i == cost_type.id) &&
                (budget_year["id"].to_i == target.id)
                  value = budget_year["units"]
                  break
             end
          end
          old_value_year = mapYearTarget[@project.start_date.year+k] == nil ? 0 : mapYearTarget[@project.start_date.year+k]
          mapYearTarget[@project.start_date.year+k] = value+old_value_year

          old_value_type_cost = mapCostTypeTarget[cost_type.id] == nil ? 0 : mapCostTypeTarget[cost_type.id]
          mapCostTypeTarget[cost_type.id] = value+old_value_type_cost


          old_value_array = array[j][k] == nil ? 0 : array[j][k]
          array[j][k] = value+old_value_array


          sheet.insert_cell(5+j+m, 2+k, '%.2f' %(value/1000000))
          sheet.sheet_data[5+j+m][2+k].change_horizontal_alignment('center')
          sheet.sheet_data[5+j+m][2+k].change_vertical_alignment('center')

          sheet.sheet_data[5+j+m][2+k].change_border(:top, 'thin')
          sheet.sheet_data[5+j+m][2+k].change_border(:left, 'thin')
          sheet.sheet_data[5+j+m][2+k].change_border(:right, 'thin')
          sheet.sheet_data[5+j+m][2+k].change_border(:bottom, 'thin')

        end

        sum_value_type_cost = mapCostTypeTarget[cost_type.id] == nil ? 0 : mapCostTypeTarget[cost_type.id]
        sheet.insert_cell(5+j+m, count_year+3, '%.2f' %(sum_value_type_cost/1000000))
        sheet.sheet_data[5+j+m][count_year+3].change_horizontal_alignment('center')
        sheet.sheet_data[5+j+m][count_year+3].change_vertical_alignment('center')

        sheet.sheet_data[5+j+m][count_year+3].change_border(:top, 'thin')
        sheet.sheet_data[5+j+m][count_year+3].change_border(:left, 'thin')
        sheet.sheet_data[5+j+m][count_year+3].change_border(:right, 'thin')
        sheet.sheet_data[5+j+m][count_year+3].change_border(:bottom, 'thin')


        count_cost_type += 1
      end

      punkt = "1." + count_target.to_s + "."
      sheet.insert_cell(4+m, 0, punkt)
      sheet.sheet_data[4+m][0].change_horizontal_alignment('center')
      sheet.sheet_data[4+m][0].change_vertical_alignment('center')

      sheet.sheet_data[4+m][0].change_border(:top, 'thin')
      sheet.sheet_data[4+m][0].change_border(:left, 'thin')
      sheet.sheet_data[4+m][0].change_border(:right, 'thin')
      sheet.sheet_data[4+m][0].change_border(:bottom, 'thin')


      sheet.insert_cell(4+m, 1, target.name)
      sheet.sheet_data[4+m][1].change_vertical_alignment('center')

      sheet.sheet_data[4+m][1].change_border(:top, 'thin')
      sheet.sheet_data[4+m][1].change_border(:left, 'thin')
      sheet.sheet_data[4+m][1].change_border(:right, 'thin')
      sheet.sheet_data[4+m][1].change_border(:bottom, 'thin')
      cell = sheet[4+m][1]
      cell.change_text_wrap(true)


      sum_value_target = 0
      for n in 0..count_year
         value_target =  mapYearTarget[@project.start_date.year+n] == nil ? 0 : mapYearTarget[@project.start_date.year+n]
         sheet.insert_cell(4+m, n+2, '%.2f' %(value_target/1000000))

         sheet.sheet_data[4+m][n+2].change_horizontal_alignment('center')
         sheet.sheet_data[4+m][n+2].change_vertical_alignment('center')

         sheet.sheet_data[4+m][n+2].change_border(:top, 'thin')
         sheet.sheet_data[4+m][n+2].change_border(:left, 'thin')
         sheet.sheet_data[4+m][n+2].change_border(:right, 'thin')
         sheet.sheet_data[4+m][n+2].change_border(:bottom, 'thin')


         sum_value_target += value_target
      end
      sheet.insert_cell(4+m, count_year+3, '%.2f' %(sum_value_target/1000000))

      sheet.sheet_data[4+m][count_year+3].change_horizontal_alignment('center')
      sheet.sheet_data[4+m][count_year+3].change_vertical_alignment('center')

      sheet.sheet_data[4+m][count_year+3].change_border(:top, 'thin')
      sheet.sheet_data[4+m][count_year+3].change_border(:left, 'thin')
      sheet.sheet_data[4+m][count_year+3].change_border(:right, 'thin')
      sheet.sheet_data[4+m][count_year+3].change_border(:bottom, 'thin')

      m += count_cost_type
    end

      mapYear = {}

    cost_types.each_with_index do |cost_type, j|

      sheet.insert_cell(5+j+m, 0, cost_type.name)
      sheet.sheet_data[5+j+m][0].change_vertical_alignment('center')
      sheet.insert_cell(5+j+m, 1, "")
      sheet.merge_cells(5+j+m, 0, 5+j+m, 1)

      sheet.sheet_data[5+j+m][0].change_border(:top, 'thin')
      sheet.sheet_data[5+j+m][0].change_border(:left, 'thin')
      sheet.sheet_data[5+j+m][0].change_border(:right, 'thin')
      sheet.sheet_data[5+j+m][0].change_border(:bottom, 'thin')

      sheet.sheet_data[5+j+m][1].change_border(:top, 'thin')
      sheet.sheet_data[5+j+m][1].change_border(:left, 'thin')
      sheet.sheet_data[5+j+m][1].change_border(:right, 'thin')
      sheet.sheet_data[5+j+m][1].change_border(:bottom, 'thin')

      cell = sheet[5+j+m][0]
      cell.change_text_wrap(true)


      sum_year = 0
      for k in 0..count_year
        sum = array[j][k] == nil ? 0 : array[j][k]
        sum_year += sum

        old_value_year = mapYear[@project.start_date.year+k] == nil ? 0 : mapYear[@project.start_date.year+k]
        mapYear[@project.start_date.year+k] = sum+old_value_year

        sheet.insert_cell(5+j+m, k+2, '%.2f' %(sum/1000000))
        sheet.sheet_data[5+j+m][k+2].change_horizontal_alignment('center')
        sheet.sheet_data[5+j+m][k+2].change_vertical_alignment('center')

        sheet.sheet_data[5+j+m][k+2].change_border(:top, 'thin')
        sheet.sheet_data[5+j+m][k+2].change_border(:left, 'thin')
        sheet.sheet_data[5+j+m][k+2].change_border(:right, 'thin')
        sheet.sheet_data[5+j+m][k+2].change_border(:bottom, 'thin')
      end


      sheet.insert_cell(5+j+m, count_year+3, '%.2f' %(sum_year/1000000))
      sheet.sheet_data[5+j+m][count_year+3].change_horizontal_alignment('center')
      sheet.sheet_data[5+j+m][count_year+3].change_vertical_alignment('center')
      sheet.sheet_data[5+j+m][count_year+3].change_border(:top, 'thin')
      sheet.sheet_data[5+j+m][count_year+3].change_border(:left, 'thin')
      sheet.sheet_data[5+j+m][count_year+3].change_border(:right, 'thin')
      sheet.sheet_data[5+j+m][count_year+3].change_border(:bottom, 'thin')

    end


    sheet.insert_cell(4+m, 0, "Всего по региональному проекту, в том числе:")
    sheet.sheet_data[4+m][0].change_vertical_alignment('center')
    sheet.insert_cell(4+m, 1, "")
    sheet.merge_cells(4+m, 0, 4+m, 1)

    sheet.sheet_data[4+m][0].change_border(:top, 'thin')
    sheet.sheet_data[4+m][0].change_border(:left, 'thin')
    sheet.sheet_data[4+m][0].change_border(:right, 'thin')
    sheet.sheet_data[4+m][0].change_border(:bottom, 'thin')

    sheet.sheet_data[4+m][1].change_border(:top, 'thin')
    sheet.sheet_data[4+m][1].change_border(:left, 'thin')
    sheet.sheet_data[4+m][1].change_border(:right, 'thin')
    sheet.sheet_data[4+m][1].change_border(:bottom, 'thin')

    cell = sheet[4+m][0]
    cell.change_text_wrap(true)

    sum_value = 0
    for n in 0..count_year
      value =  mapYear[@project.start_date.year+n] == nil ? 0 : mapYear[@project.start_date.year+n]
      sheet.insert_cell(4+m, n+2, '%.2f' %(value/1000000))

      sheet.sheet_data[4+m][n+2].change_horizontal_alignment('center')
      sheet.sheet_data[4+m][n+2].change_vertical_alignment('center')

      sheet.sheet_data[4+m][n+2].change_border(:top, 'thin')
      sheet.sheet_data[4+m][n+2].change_border(:left, 'thin')
      sheet.sheet_data[4+m][n+2].change_border(:right, 'thin')
      sheet.sheet_data[4+m][n+2].change_border(:bottom, 'thin')


      sum_value += value
    end
    sheet.insert_cell(4+m, count_year+3, '%.2f' %(sum_value/1000000))

    sheet.sheet_data[4+m][count_year+3].change_horizontal_alignment('center')
    sheet.sheet_data[4+m][count_year+3].change_vertical_alignment('center')

    sheet.sheet_data[4+m][count_year+3].change_border(:top, 'thin')
    sheet.sheet_data[4+m][count_year+3].change_border(:left, 'thin')
    sheet.sheet_data[4+m][count_year+3].change_border(:right, 'thin')
    sheet.sheet_data[4+m][count_year+3].change_border(:bottom, 'thin')


  end


  def generate_members_sheet

    sheet = @workbook['Участники']

    str_ids = get_str_ids_result_members

    @curatorsProject.each_with_index do |user, i|
      member_info = get_member_info(user)
      direct_manager = User.find_by(id: user.direct_manager_id)
      direct__manager_fio = direct_manager == nil ? "" : direct_manager.name(:lastname_f_p)
      sheet.insert_cell(2+i, 0, (i+1).to_s)
      sheet.insert_cell(2+i, 1, member_info["role"])
      sheet.insert_cell(2+i, 2, user.name(:lastname_f_p))
      sheet.insert_cell(2+i, 3, member_info["position"])
      sheet.insert_cell(2+i, 4, direct__manager_fio)
      sheet.insert_cell(2+i, 5, member_info["busyness"].to_s)

      str_ids = (str_ids =="" ? user.id.to_s : str_ids += ", "+user.id.to_s)

      sheet.sheet_data[2+i][0].change_horizontal_alignment('center')
      sheet.sheet_data[2+i][0].change_vertical_alignment('center')

      sheet.sheet_data[2+i][5].change_horizontal_alignment('center')
      sheet.sheet_data[2+i][5].change_vertical_alignment('center')

      sheet.sheet_data[2+i][0].change_border(:top, 'thin')
      sheet.sheet_data[2+i][0].change_border(:left, 'thin')
      sheet.sheet_data[2+i][0].change_border(:right, 'thin')
      sheet.sheet_data[2+i][0].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i][1].change_border(:top, 'thin')
      sheet.sheet_data[2+i][1].change_border(:left, 'thin')
      sheet.sheet_data[2+i][1].change_border(:right, 'thin')
      sheet.sheet_data[2+i][1].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i][2].change_border(:top, 'thin')
      sheet.sheet_data[2+i][2].change_border(:left, 'thin')
      sheet.sheet_data[2+i][2].change_border(:right, 'thin')
      sheet.sheet_data[2+i][2].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i][3].change_border(:top, 'thin')
      sheet.sheet_data[2+i][3].change_border(:left, 'thin')
      sheet.sheet_data[2+i][3].change_border(:right, 'thin')
      sheet.sheet_data[2+i][3].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i][4].change_border(:top, 'thin')
      sheet.sheet_data[2+i][4].change_border(:left, 'thin')
      sheet.sheet_data[2+i][4].change_border(:right, 'thin')
      sheet.sheet_data[2+i][4].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i][5].change_border(:top, 'thin')
      sheet.sheet_data[2+i][5].change_border(:left, 'thin')
      sheet.sheet_data[2+i][5].change_border(:right, 'thin')
      sheet.sheet_data[2+i][5].change_border(:bottom, 'thin')

    end
    countUser = @curatorsProject.count
    @leadersProject.each_with_index do |user, i|

      direct_manager = User.find_by(id: user.direct_manager_id)
      direct__manager_fio = direct_manager == nil ? "" : direct_manager.name(:lastname_f_p)

      member_info = get_member_info(user)
      sheet.insert_cell(2+i+countUser, 0, (i+1+countUser).to_s)
      sheet.insert_cell(2+i+countUser, 1, member_info["role"])
      sheet.insert_cell(2+i+countUser, 2, user.name(:lastname_f_p))
      sheet.insert_cell(2+i+countUser, 3, member_info["position"])
      sheet.insert_cell(2+i+countUser, 4, direct__manager_fio)
      sheet.insert_cell(2+i+countUser, 5, member_info["busyness"].to_s)

      str_ids = (str_ids =="" ? user.id.to_s : str_ids += ", "+user.id.to_s)

      sheet.sheet_data[2+i+countUser][5].change_horizontal_alignment('center')
      sheet.sheet_data[2+i+countUser][5].change_vertical_alignment('center')

      sheet.sheet_data[2+i+countUser][0].change_horizontal_alignment('center')
      sheet.sheet_data[2+i+countUser][0].change_vertical_alignment('center')

      sheet.sheet_data[2+i+countUser,][0].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser,][0].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser,][0].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser,][0].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser,][1].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser,][1].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser,][1].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser,][1].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser,][2].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser,][2].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser,][2].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser,][2].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser,][3].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser,][3].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser,][3].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser,][3].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser,][4].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser,][4].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser,][4].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser,][4].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser,][5].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser,][5].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser,][5].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser,][5].change_border(:bottom, 'thin')

    end
    countUser += @leadersProject.count
    @adminsProject.each_with_index do |user, i|

      direct_manager = User.find_by(id: user.direct_manager_id)
      direct__manager_fio = direct_manager == nil ? "" : direct_manager.name(:lastname_f_p)

      member_info = get_member_info(user)
      sheet.insert_cell(2+i+countUser, 0, (i+1+countUser).to_s)
      sheet.insert_cell(2+i+countUser, 1, member_info["role"])
      sheet.insert_cell(2+i+countUser, 2, user.name(:lastname_f_p))
      sheet.insert_cell(2+i+countUser, 3, member_info["position"])
      sheet.insert_cell(2+i+countUser, 4, direct__manager_fio)
      sheet.insert_cell(2+i+countUser, 5, member_info["busyness"].to_s)

      str_ids = str_ids == "" ? user.id.to_s : str_ids += ", "+user.id.to_s

      sheet.sheet_data[2+i+countUser][0].change_horizontal_alignment('center')
      sheet.sheet_data[2+i+countUser][0].change_vertical_alignment('center')

      sheet.sheet_data[2+i+countUser][5].change_horizontal_alignment('center')
      sheet.sheet_data[2+i+countUser][5].change_vertical_alignment('center')

      sheet.sheet_data[2+i+countUser][0].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser][0].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser][0].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser][0].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser][1].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser][1].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser][1].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser][1].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser][2].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser][2].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser][2].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser][2].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser][3].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser][3].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser][3].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser][3].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser][4].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser][4].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser][4].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser][4].change_border(:bottom, 'thin')

      sheet.sheet_data[2+i+countUser][5].change_border(:top, 'thin')
      sheet.sheet_data[2+i+countUser][5].change_border(:left, 'thin')
      sheet.sheet_data[2+i+countUser][5].change_border(:right, 'thin')
      sheet.sheet_data[2+i+countUser][5].change_border(:bottom, 'thin')

    end

    start_position = countUser + 4
    sheet.insert_cell(start_position-1, 0, "Общие организационные мероприятия по региональному проекту")
    sheet.insert_cell(start_position-1, 1, "")
    sheet.insert_cell(start_position-1, 2, "")
    sheet.insert_cell(start_position-1, 3, "")
    sheet.insert_cell(start_position-1, 4, "")
    sheet.insert_cell(start_position-1, 5, "")
    sheet.merge_cells(start_position-1, 0, start_position-1, 5)
    sheet.sheet_data[start_position-1][0].change_border(:top, 'thin')
    sheet.sheet_data[start_position-1][0].change_border(:left, 'thin')
    sheet.sheet_data[start_position-1][0].change_border(:right, 'thin')
    sheet.sheet_data[start_position-1][0].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position-1][1].change_border(:top, 'thin')
    sheet.sheet_data[start_position-1][1].change_border(:left, 'thin')
    sheet.sheet_data[start_position-1][1].change_border(:right, 'thin')
    sheet.sheet_data[start_position-1][1].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position-1][2].change_border(:top, 'thin')
    sheet.sheet_data[start_position-1][2].change_border(:left, 'thin')
    sheet.sheet_data[start_position-1][2].change_border(:right, 'thin')
    sheet.sheet_data[start_position-1][2].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position-1][3].change_border(:top, 'thin')
    sheet.sheet_data[start_position-1][3].change_border(:left, 'thin')
    sheet.sheet_data[start_position-1][3].change_border(:right, 'thin')
    sheet.sheet_data[start_position-1][3].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position-1][4].change_border(:top, 'thin')
    sheet.sheet_data[start_position-1][4].change_border(:left, 'thin')
    sheet.sheet_data[start_position-1][4].change_border(:right, 'thin')
    sheet.sheet_data[start_position-1][4].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position-1][5].change_border(:top, 'thin')
    sheet.sheet_data[start_position-1][5].change_border(:left, 'thin')
    sheet.sheet_data[start_position-1][5].change_border(:right, 'thin')
    sheet.sheet_data[start_position-1][5].change_border(:bottom, 'thin')


    incriment = 0
    decriment_result = 0
    get_result_target.each do |result_target|
      sheet.insert_cell(start_position+incriment, 0, result_target.name)
      cell = sheet[start_position+incriment][0]
      cell.change_text_wrap(true)
      sheet.insert_cell(start_position+incriment, 1, "")
      sheet.insert_cell(start_position+incriment, 2, "")
      sheet.insert_cell(start_position+incriment, 3, "")
      sheet.insert_cell(start_position+incriment, 4, "")
      sheet.insert_cell(start_position+incriment, 5, "")
      sheet.merge_cells(start_position+incriment, 0, start_position+incriment, 5)
      sheet.sheet_data[start_position+incriment][0].change_border(:left, 'thin')
      sheet.sheet_data[start_position+incriment][5].change_border(:right, 'thin')

      result_members = get_result_member(result_target.id.to_s)

      result_members.each do |result_member|

        sheet.insert_cell(start_position+1+incriment, 0, (incriment+4-decriment_result).to_s)
        role = result_member["role"]

        sheet.insert_cell(start_position+1+incriment, 1, role)
        user_id = result_member["user_id"]
        str_ids = str_ids == "" ? user_id.to_s : str_ids += ", "+user_id.to_s
        member = User.find_by(id: user_id)
        direct_manager = User.find_by(id: member.direct_manager_id)
        direct__manager_fio = direct_manager == nil ? "" : direct_manager.name(:lastname_f_p)

        fio = member.name(:lastname_f_p)
        sheet.insert_cell(start_position+1+incriment, 2, fio)
        position = result_member["position"]
        member_info = get_member_info(member)

        sheet.insert_cell(start_position+1+incriment, 3, position)
        sheet.insert_cell(start_position+1+incriment, 4, direct__manager_fio)
        sheet.insert_cell(start_position+1+incriment, 5, member_info["busyness"].to_s)

        sheet.sheet_data[start_position+1+incriment][5].change_horizontal_alignment('center')
        sheet.sheet_data[start_position+1+incriment][5].change_vertical_alignment('center')

      end
      if (result_members.count == 0)
        sheet.insert_cell(start_position+1+incriment, 0, (incriment+4-decriment_result).to_s)
        sheet.insert_cell(start_position+1+incriment, 1, "")
        sheet.insert_cell(start_position+1+incriment, 2, "")
        sheet.insert_cell(start_position+1+incriment, 3, "")
        sheet.insert_cell(start_position+1+incriment, 4, "")
        sheet.insert_cell(start_position+1+incriment, 5, "")
      end

      sheet.sheet_data[start_position+1+incriment][0].change_horizontal_alignment('center')
      sheet.sheet_data[start_position+1+incriment][0].change_vertical_alignment('center')

      sheet.sheet_data[start_position+1+incriment][0].change_horizontal_alignment('center')
      sheet.sheet_data[start_position+1+incriment][0].change_vertical_alignment('center')

      sheet.sheet_data[start_position+1+incriment][0].change_border(:top, 'thin')
      sheet.sheet_data[start_position+1+incriment][0].change_border(:left, 'thin')
      sheet.sheet_data[start_position+1+incriment][0].change_border(:right, 'thin')
      sheet.sheet_data[start_position+1+incriment][0].change_border(:bottom, 'thin')

      sheet.sheet_data[start_position+1+incriment][1].change_border(:top, 'thin')
      sheet.sheet_data[start_position+1+incriment][1].change_border(:left, 'thin')
      sheet.sheet_data[start_position+1+incriment][1].change_border(:right, 'thin')
      sheet.sheet_data[start_position+1+incriment][1].change_border(:bottom, 'thin')

      sheet.sheet_data[start_position+1+incriment][2].change_border(:top, 'thin')
      sheet.sheet_data[start_position+1+incriment][2].change_border(:left, 'thin')
      sheet.sheet_data[start_position+1+incriment][2].change_border(:right, 'thin')
      sheet.sheet_data[start_position+1+incriment][2].change_border(:bottom, 'thin')

      sheet.sheet_data[start_position+1+incriment][3].change_border(:top, 'thin')
      sheet.sheet_data[start_position+1+incriment][3].change_border(:left, 'thin')
      sheet.sheet_data[start_position+1+incriment][3].change_border(:right, 'thin')
      sheet.sheet_data[start_position+1+incriment][3].change_border(:bottom, 'thin')

      sheet.sheet_data[start_position+1+incriment][4].change_border(:top, 'thin')
      sheet.sheet_data[start_position+1+incriment][4].change_border(:left, 'thin')
      sheet.sheet_data[start_position+1+incriment][4].change_border(:right, 'thin')
      sheet.sheet_data[start_position+1+incriment][4].change_border(:bottom, 'thin')

      sheet.sheet_data[start_position+1+incriment][5].change_border(:top, 'thin')
      sheet.sheet_data[start_position+1+incriment][5].change_border(:left, 'thin')
      sheet.sheet_data[start_position+1+incriment][5].change_border(:right, 'thin')
      sheet.sheet_data[start_position+1+incriment][5].change_border(:bottom, 'thin')

      incriment += 2
      decriment_result += 1

    end



    sheet.insert_cell(start_position+incriment, 0, "")
    sheet.insert_cell(start_position+incriment, 1, "")
    sheet.insert_cell(start_position+incriment, 2, "")
    sheet.insert_cell(start_position+incriment, 3, "")
    sheet.insert_cell(start_position+incriment, 4, "")
    sheet.insert_cell(start_position+incriment, 5, "")

    sheet.sheet_data[start_position+incriment][0].change_horizontal_alignment('center')
    sheet.sheet_data[start_position+incriment][0].change_vertical_alignment('center')


    sheet.sheet_data[start_position+incriment][0].change_border(:top, 'thin')
    sheet.sheet_data[start_position+incriment][0].change_border(:left, 'thin')
    sheet.sheet_data[start_position+incriment][0].change_border(:right, 'thin')
    sheet.sheet_data[start_position+incriment][0].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position+incriment][1].change_border(:top, 'thin')
    sheet.sheet_data[start_position+incriment][1].change_border(:left, 'thin')
    sheet.sheet_data[start_position+incriment][1].change_border(:right, 'thin')
    sheet.sheet_data[start_position+incriment][1].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position+incriment][2].change_border(:top, 'thin')
    sheet.sheet_data[start_position+incriment][2].change_border(:left, 'thin')
    sheet.sheet_data[start_position+incriment][2].change_border(:right, 'thin')
    sheet.sheet_data[start_position+incriment][2].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position+incriment][3].change_border(:top, 'thin')
    sheet.sheet_data[start_position+incriment][3].change_border(:left, 'thin')
    sheet.sheet_data[start_position+incriment][3].change_border(:right, 'thin')
    sheet.sheet_data[start_position+incriment][3].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position+incriment][4].change_border(:top, 'thin')
    sheet.sheet_data[start_position+incriment][4].change_border(:left, 'thin')
    sheet.sheet_data[start_position+incriment][4].change_border(:right, 'thin')
    sheet.sheet_data[start_position+incriment][4].change_border(:bottom, 'thin')

    sheet.sheet_data[start_position+incriment][5].change_border(:top, 'thin')
    sheet.sheet_data[start_position+incriment][5].change_border(:left, 'thin')
    sheet.sheet_data[start_position+incriment][5].change_border(:right, 'thin')
    sheet.sheet_data[start_position+incriment][5].change_border(:bottom, 'thin')



    str_ids = str_ids == "" ? "0" : str_ids

    decriment = 0
    members = get_members(str_ids)
    members.each_with_index do |member, i|

      direct_manager = User.find_by(id: member.direct_manager_id)
      direct__manager_fio = direct_manager == nil ? "" : direct_manager.name(:lastname_f_p)


      member_info = get_member_info(member)
      if member_info["role"] == I18n.t(:default_role_glava_regiona) ||
        member_info["role"] == I18n.t(:default_role_project_activity_coordinator) ||
        member_info["role"] == I18n.t(:default_role_project_office_manager)
        decriment += 1
      else
        sheet.insert_cell(start_position+1+i-decriment+incriment, 0, (incriment+4-decriment_result-decriment+i).to_s)
        sheet.insert_cell(start_position+1+i-decriment+incriment, 1, member_info["role"])
        sheet.insert_cell(start_position+1+i+-decriment+incriment, 2, member.name(:lastname_f_p))
        sheet.insert_cell(start_position+1+i+-decriment+incriment, 3, member_info["position"])
        sheet.insert_cell(start_position+1+i+-decriment+incriment, 4, direct__manager_fio)
        sheet.insert_cell(start_position+1+i+-decriment+incriment, 5, member_info["busyness"].to_s)

        sheet.sheet_data[start_position+1+i-decriment+incriment][0].change_horizontal_alignment('center')
        sheet.sheet_data[start_position+1+i-decriment+incriment][0].change_vertical_alignment('center')

        sheet.sheet_data[start_position+1+i-decriment+incriment][5].change_horizontal_alignment('center')
        sheet.sheet_data[start_position+1+i-decriment+incriment][5].change_vertical_alignment('center')

        sheet.sheet_data[start_position+1+i-decriment+incriment][0].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][0].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][0].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][0].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+i-decriment+incriment][1].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][1].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][1].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][1].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+i-decriment+incriment][2].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][2].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][2].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][2].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+i-decriment+incriment][3].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][3].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][3].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][3].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+i-decriment+incriment][4].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][4].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][4].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][4].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+i-decriment+incriment][5].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][5].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][5].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+i-decriment+incriment][5].change_border(:bottom, 'thin')

      end
    end

  end

  def generate_additonal_info
    sheet = @workbook['Дополнительная информация ']
    sheet[1][0].change_contents(@project.description)
  end

  def generate_plan_sheet
    sheet = @workbook['План']
    sheet[3][5].change_contents(@project.name)

    @id_type_target = Enumeration.find_by(name: I18n.t(:default_target)).id
    @id_type_result = Enumeration.find_by(name: I18n.t(:default_result)).id
    @id_type_kt = Type.find_by(name: I18n.t(:default_type_milestone)).id
    @id_type_task = Type.find_by(name: I18n.t(:default_type_task)).id

    str_ids_kt = ""
    start_index = 11
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

        username = result["result_assigned"] == nil ? "" : user = User.find(result["result_assigned"]).name(:lastname_f_p)
        start_date = result["basic_date"] == nil ? nil : result["basic_date"].to_date.strftime("%d.%m.%Y")
        due_date = result["result_due_date"] == nil ? nil : result["result_due_date"].to_date.strftime("%d.%m.%Y")
        target = Target.find(result["parent_id"])

        sheet.insert_cell(start_index+i+k, 0, numberTarget)
        sheet.insert_cell(start_index+i+k, 1, target.name)
        sheet.insert_cell(start_index+i+k, 2, start_date)
        sheet.insert_cell(start_index+i+k, 3, due_date)
        sheet.insert_cell(start_index+i+k, 4, username)
        sheet.insert_cell(start_index+i+k, 5, "")
        sheet.insert_cell(start_index+i+k, 6, "")

        sheet[start_index+i+k][1].change_text_wrap(true)
        sheet[start_index+i+k][4].change_text_wrap(true)

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


          username = result["result_assigned"] == nil ? "" : user = User.find(result["result_assigned"]).name(:lastname_f_p)
          start_date = result["basic_date"] == nil ? nil : result["basic_date"].to_date.strftime("%d.%m.%Y")
          due_date = result["result_due_date"] == nil ? nil : result["result_due_date"].to_date.strftime("%d.%m.%Y")

          sheet.insert_cell(start_index+i+k, 0, numberResult)
          sheet.insert_cell(start_index+i+k, 1, result["name"])
          sheet.insert_cell(start_index+i+k, 2, start_date)
          sheet.insert_cell(start_index+i+k, 3, due_date)
          sheet.insert_cell(start_index+i+k, 4, username)
          sheet.insert_cell(start_index+i+k, 5, "")
          sheet.insert_cell(start_index+i+k, 6, "")

          sheet[start_index+i+k][1].change_text_wrap(true)
          sheet[start_index+i+k][4].change_text_wrap(true)

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


          target_id = result["target_id"]
          start_index += 1
          index += 1
          numberKT = 0
          map[1] = index
          common_count = start_index+i+k
        end

     if result["work_packages_id"] != nil
        if result["work_packages_id"] != work_packages_id
           username = result["user_id"] == nil ? "" : user = User.find(result["user_id"]).name(:lastname_f_p)
           start_date = result["start_date"] == nil ? nil : result["start_date"].to_date.strftime("%d.%m.%Y")
           due_date = result["due_date"] == nil ? nil : result["due_date"].to_date.strftime("%d.%m.%Y")
           numberKT += 1
           numberResultKt = numberResult+numberKT.to_s+"."
           sheet.insert_cell(start_index+i+k, 0, numberResultKt)
           sheet.insert_cell(start_index+i+k, 1, result["subject"])
           sheet.insert_cell(start_index+i+k, 2, start_date)
           sheet.insert_cell(start_index+i+k, 3, due_date)
           sheet.insert_cell(start_index+i+k, 4, username)
           sheet.insert_cell(start_index+i+k, 5, result["document"])
           sheet.insert_cell(start_index+i+k, 6, result["control_level"])

           sheet[start_index+i+k][1].change_text_wrap(true)
           sheet[start_index+i+k][4].change_text_wrap(true)

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
            user = User.find(ktTask["user_id"])
            username = user.name(:lastname_f_p)
            start_date = ktTask["start_date"] == nil ? nil : ktTask["start_date"].to_date.strftime("%d.%m.%Y")
            due_date = ktTask["due_date"] == nil ? nil : ktTask["due_date"].to_date.strftime("%d.%m.%Y")

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

            #punkt = map[1].to_s + "." + map[2].to_s + "."
            punkt = numberResultKt
            for l in 3..level
              punkt += map[l].to_s + "."
            end


            sheet.insert_cell(start_index+i+j+k, 0, punkt)
            sheet.insert_cell(start_index+i+j+k, 1, ktTask["subject"])
            sheet.insert_cell(start_index+i+j+k, 2, start_date)
            sheet.insert_cell(start_index+i+j+k, 3, due_date)
            sheet.insert_cell(start_index+i+j+k, 4, username)
            sheet.insert_cell(start_index+i+j+k, 5, ktTask["document"])
            sheet.insert_cell(start_index+i+j+k, 6, ktTask["control_level"])

            sheet[start_index+i+j+k][1].change_text_wrap(true)
            sheet[start_index+i+j+k][4].change_text_wrap(true)

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
            common_count = start_index+i+j+k
        end

        if ktTasks.count != 0
          k += ktTasks.count - 1
        end
     else
       start_index -= 1
     end

    end

    start_index = common_count == 0 ? 10 : common_count

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
        user = User.find(ktTask["user_id"])
        username = user.name(:lastname_f_p)
        start_date = ktTask["start_date"] == nil ? nil : ktTask["start_date"].to_date.strftime("%d.%m.%Y")
        due_date = ktTask["due_date"] == nil ? nil : ktTask["due_date"].to_date.strftime("%d.%m.%Y")


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

        sheet.insert_cell(start_index+i+j+k, 0, punkt)
        sheet.insert_cell(start_index+i+j+k, 1, ktTask["subject"])
        sheet.insert_cell(start_index+i+j+k, 2, start_date)
        sheet.insert_cell(start_index+i+j+k, 3, due_date)
        sheet.insert_cell(start_index+i+j+k, 4, username)
        sheet.insert_cell(start_index+i+j+k, 5, ktTask["document"])
        sheet.insert_cell(start_index+i+j+k, 6, ktTask["control_level"])

        sheet[start_index+i+j+k][1].change_text_wrap(true)
        sheet[start_index+i+j+k][4].change_text_wrap(true)

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

      end

      if ktTasks.count != 0
        k += ktTasks.count - 2
      end


    end

  end

  def generate_method_calc_sheet
    sheet = @workbook['Методика расчета']
    sheet[3][5].change_contents(@project.name)

    targetCalcProcedures = TargetCalcProcedure.where(project_id: @project.id).order('target_id')
    start_index = 9
    target_id = 0
    index = 0
    targetCalcProcedures.each_with_index do |targetCalcProcedure, i|
    if targetCalcProcedure.target_id != target_id && targetCalcProcedure.target!=nil
       sheet.insert_cell(start_index+i, 0, targetCalcProcedure.target.name)
       sheet.insert_cell(start_index+i, 1, "")
       sheet.insert_cell(start_index+i, 2, "")
       sheet.insert_cell(start_index+i, 3, "")
       sheet.insert_cell(start_index+i, 4, "")
       sheet.insert_cell(start_index+i, 5, "")
       sheet.insert_cell(start_index+i, 6, "")
       sheet.insert_cell(start_index+i, 7, "")
       sheet.merge_cells(start_index+i, 0, start_index+i, 7)
       sheet.sheet_data[start_index+i][0].change_border(:left, 'thin')
       sheet.sheet_data[start_index+i][7].change_border(:right, 'thin')

       target_id = targetCalcProcedure.target_id
       start_index += 1
       index = 0
    end

    period =""
    if targetCalcProcedure.period.downcase == "daily"
      period = 'Ежедневно'
    elsif targetCalcProcedure.period.downcase == "weekly"
      period = 'Еженедельно'
    elsif targetCalcProcedure.period.downcase == "monthly"
      period = 'Ежемесячно'
    elsif targetCalcProcedure.period.downcase == "quarterly"
      period = 'Ежеквартально'
    elsif targetCalcProcedure.period.downcase == "yearly"
      period = 'Ежегодно'
    end

    punkt = (index+1).to_s+"."
    sheet.insert_cell(start_index+i, 0, punkt)
    sheet.insert_cell(start_index+i, 1, targetCalcProcedure.name)
    base_target_name = targetCalcProcedure.base_target == nil ? "" : targetCalcProcedure.base_target.name
    sheet.insert_cell(start_index+i, 2, base_target_name)
    sheet.insert_cell(start_index+i, 3, targetCalcProcedure.data_source)
    sheet.insert_cell(start_index+i, 4, targetCalcProcedure.user.name(:lastname_f_p))
    sheet.insert_cell(start_index+i, 5, targetCalcProcedure.level)
    sheet.insert_cell(start_index+i, 6, period)
    sheet.insert_cell(start_index+i, 7, targetCalcProcedure.add_info)

    index = index+1

    sheet[start_index+i][0].change_text_wrap(true)
    sheet[start_index+i][1].change_text_wrap(true)
    sheet[start_index+i][2].change_text_wrap(true)
    sheet[start_index+i][3].change_text_wrap(true)
    sheet[start_index+i][4].change_text_wrap(true)
    sheet[start_index+i][5].change_text_wrap(true)
    sheet[start_index+i][6].change_text_wrap(true)
    sheet[start_index+i][7].change_text_wrap(true)

    sheet.sheet_data[start_index+i][0].change_border(:top, 'thin')
    sheet.sheet_data[start_index+i][0].change_border(:left, 'thin')
    sheet.sheet_data[start_index+i][0].change_border(:right, 'thin')
    sheet.sheet_data[start_index+i][0].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index+i][1].change_border(:top, 'thin')
    sheet.sheet_data[start_index+i][1].change_border(:left, 'thin')
    sheet.sheet_data[start_index+i][1].change_border(:right, 'thin')
    sheet.sheet_data[start_index+i][1].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index+i][2].change_border(:top, 'thin')
    sheet.sheet_data[start_index+i][2].change_border(:left, 'thin')
    sheet.sheet_data[start_index+i][2].change_border(:right, 'thin')
    sheet.sheet_data[start_index+i][2].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index+i][3].change_border(:top, 'thin')
    sheet.sheet_data[start_index+i][3].change_border(:left, 'thin')
    sheet.sheet_data[start_index+i][3].change_border(:right, 'thin')
    sheet.sheet_data[start_index+i][3].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index+i][4].change_border(:top, 'thin')
    sheet.sheet_data[start_index+i][4].change_border(:left, 'thin')
    sheet.sheet_data[start_index+i][4].change_border(:right, 'thin')
    sheet.sheet_data[start_index+i][4].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index+i][5].change_border(:top, 'thin')
    sheet.sheet_data[start_index+i][5].change_border(:left, 'thin')
    sheet.sheet_data[start_index+i][5].change_border(:right, 'thin')
    sheet.sheet_data[start_index+i][5].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index+i][6].change_border(:top, 'thin')
    sheet.sheet_data[start_index+i][6].change_border(:left, 'thin')
    sheet.sheet_data[start_index+i][6].change_border(:right, 'thin')
    sheet.sheet_data[start_index+i][6].change_border(:bottom, 'thin')

    sheet.sheet_data[start_index+i][7].change_border(:top, 'thin')
    sheet.sheet_data[start_index+i][7].change_border(:left, 'thin')
    sheet.sheet_data[start_index+i][7].change_border(:right, 'thin')
    sheet.sheet_data[start_index+i][7].change_border(:bottom, 'thin')

    end
  end




  def get_budjet_by_cost_type_and_year
    sql  = "  select t.id, t.name,t.national_project_result, m.units,m.plan_year, m.cost_type_id, ct.name as cost_type_name
              FROM targets t
              left join cost_objects co on co.target_id = t.id
              left join material_budget_items m on m.cost_object_id = co.id
              left join work_packages wp on wp.cost_object_id = co.id
              left join cost_types ct on ct.id = m.cost_type_id
              inner join enumerations e on e.id = t.type_id
              where t.project_id = " + @project.id.to_s+" and e.name = '"+I18n.t(:default_result)+"'
              order by t.id, ct.id"
    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []
    result.each do |row|
      result_array[index] = row
      index += 1
    end
    result_array
  end

  def get_member_by_role(role_name)
  userList = User.find_by_sql("  SELECT u.* FROM users u
                                           INNER JOIN members  m ON m.user_id = u.id
                                           INNER JOIN member_roles mr ON  mr.member_id = m.id
                                           INNER JOIN roles r ON  mr.role_id = r.id and r.name ='" +role_name+"' "+
                                          "INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s)

  userList
  end

  def get_members(str_ids)
    userList = User.find_by_sql("  SELECT u.* FROM users u
                                   INNER JOIN members  m ON m.user_id = u.id
                                   INNER JOIN projects p ON m.project_id = p.id
                                   WHERE u.id not in ("+str_ids+") and p.id = " + @project.id.to_s)
    userList
  end


  def get_str_ids_result_members
    sql  = " SELECT u.id FROM users u
             INNER JOIN members  m ON m.user_id = u.id
             INNER JOIN member_roles mr ON  mr.member_id = m.id
             INNER JOIN roles r ON  mr.role_id = r.id
             LEFT JOIN positions ps ON ps.id = u.position_id
             INNER JOIN work_packages w ON w.assigned_to_id = u.id
             INNER JOIN work_package_targets wt ON wt.work_package_id = w.id
             INNER JOIN targets t ON t.id = wt.target_id
             INNER JOIN enumerations e ON e.id = t.type_id and e.name = '"+I18n.t(:default_result)+"'
             INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s
    result = ActiveRecord::Base.connection.execute(sql)

    str_set_result = ""
    index = 0
    result.each do |row|
      if index  == 0
       str_set_result += row["id"].to_s
      else
        str_set_result += ", "+row["id"].to_s
      end
      index += 1
    end
    str_set_result
  end



  def get_result_member(target_id)
    sql  = " SELECT u.id as user_id, r.name as role, coalesce(ps.name, '') as position FROM users u
             INNER JOIN members  m ON m.user_id = u.id
             INNER JOIN member_roles mr ON  mr.member_id = m.id
             INNER JOIN roles r ON  mr.role_id = r.id
             LEFT JOIN positions ps ON ps.id = u.position_id
             INNER JOIN work_packages w ON w.assigned_to_id = u.id
             INNER JOIN work_package_targets wt ON wt.work_package_id = w.id
             INNER JOIN targets t ON t.id = wt.target_id and t.id = "+target_id +" and t.is_approve=true
             INNER JOIN enumerations e ON e.id = t.type_id and e.name = '"+I18n.t(:default_result)+"'
             INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s
    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []
    result.each do |row|
      result_array[index] = row
      index += 1
    end
    result_array
  end


  def get_member_info(user)
    sql  = " SELECT u.id as user_id, r.name as role, coalesce(ps.name, '') as position, m.busyness FROM users u
             INNER JOIN members  m ON m.user_id = u.id
             INNER JOIN member_roles mr ON  mr.member_id = m.id
             INNER JOIN roles r ON  mr.role_id = r.id
             LEFT JOIN positions ps ON ps.id = u.position_id
             INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s+
           " WHERE u.id = "+user.id.to_s
    result_sql = ActiveRecord::Base.connection.execute(sql)
    result = result_sql[0]
  end


    def get_result
    sql  = "SELECT t.parent_id, t.id as target_id,t.name, t.result_due_date, t.result_assigned, t.basic_date, w.id as work_packages_id,
               w.subject,
               w.type_id,
               w.start_date,
               w.due_date,
               u.id    as user_id,
               ed.name as document,
               cl.name as control_level
            FROM targets t
                   INNER JOIN enumerations e ON e.id = t.type_id and e.name = '"+I18n.t(:default_result)+"'
                   LEFT JOIN work_package_targets wt ON wt.target_id = t.id
                   LEFT JOIN work_packages w ON w.id = wt.work_package_id
                   LEFT OUTER JOIN users u ON w.assigned_to_id = u.id
                   LEFT OUTER JOIN enumerations ed ON ed.id = w.required_doc_type_id
                   LEFT OUTER JOIN control_levels cl ON cl.id = w.control_level_id
            WHERE t.project_id = "+ @project.id.to_s +
          " GROUP BY t.parent_id, t.id, t.name, t.result_due_date, t.result_assigned, t.plan_date, w.id, w.subject, w.type_id, w.start_date, w.due_date, u.id, ed.name, cl.name
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
                            u.id    as user_id,
                            ed.name as document
            FROM work_packages w
                   LEFT OUTER JOIN users u ON w.assigned_to_id = u.id
                   LEFT OUTER JOIN enumerations ed ON ed.id = w.required_doc_type_id
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
         SELECT t.*, l.level+1 as level, l.path, cl.name as control_level from LEVEL l, TASK t
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
                            u.id    as user_id,
                            ed.name as document
            FROM work_packages w
                   LEFT OUTER JOIN users u ON w.assigned_to_id = u.id
                   LEFT OUTER JOIN enumerations ed ON ed.id = w.required_doc_type_id
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
         SELECT t.*, l.level as level, l.path, cl.name as control_level from LEVEL l, TASK t
         INNER JOIN work_packages w ON w.id = t.work_packages_id
         LEFT OUTER JOIN control_levels cl ON cl.id = w.control_level_id

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


  def get_name_target
    sql = " select t.name
            FROM targets t
            inner join enumerations e on e.id = t.type_id
            where t.is_approve=true and e.name = '"+I18n.t(:default_target)+"' and t.project_id = "+ @project.id.to_s


    result_sql = ActiveRecord::Base.connection.execute(sql)

    index = 0

    result_name = ""
    result_sql.each do |row|
      if index == 0
        result_name += row["name"]
      else
        result_name += ", "+row["name"]
      end
      index += 1
    end

    result_name

  end

  def get_result_target

    targetList = Target.find_by_sql(" select t.*
                                      FROM targets t
                                      inner join enumerations e on e.id = t.type_id
                                      where t.is_approve=true and e.name = '"+I18n.t(:default_result)+"' and t.project_id = "+ @project.id.to_s)
    targetList
  end

  def get_result_target_end_date

    sql  = "with
    result_end as (
    select s.id, s.name,  s.name_measure_unit, s.okei_code, substring(max(s.union_val), 1, 4) as year, substring(max(s.union_val), 5, 1) as quarter, max(s.union_val) as union_val
    from (
            select t.id, t.name, m.name as name_measure_unit, m.okei_code, concat(cast(tev.year as varchar), cast(tev.quarter as varchar)) as union_val
            FROM targets t
                    inner join enumerations e on e.id = t.type_id
                    left join target_execution_values tev on tev.target_id = t.id
                    left join measure_units m on t.measure_unit_id = m.id
            where t.is_approve = true
              and e.name = '"+I18n.t(:default_result)+"'
              and t.project_id = "  + @project.id.to_s + "
         ) as s
    group by s.id, s.name,  s.name_measure_unit, s.okei_code
   ),

   result_end_value as (

            select t.id,t.national_project_charact, t.result_due_date, tev.value, cast(tev.year as varchar) as year, cast(tev.quarter as varchar) as quarter, concat(cast(tev.year as varchar), cast(tev.quarter as varchar)) as union_val
            FROM targets t
                    inner join enumerations e on e.id = t.type_id
                    left join target_execution_values tev on tev.target_id = t.id
            where t.is_approve = true
              and e.name = '"+I18n.t(:default_result)+"'
              and t.project_id = " + @project.id.to_s + "
    )

  select re.*, rev.national_project_charact, rev.result_due_date, rev.value from result_end re
  left join result_end_value rev on rev.id=re.id and re.union_val = rev.union_val"

    result = ActiveRecord::Base.connection.execute(sql)
    index = 0
    result_array = []
    result.each do |row|
      result_array[index] = row
      index += 1
    end
    result_array
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
            where t.is_approve=true and e.name = '"+I18n.t(:default_result)+"' and t.id = "+target_id +" and t.project_id = "+ @project.id.to_s

    result_sql = ActiveRecord::Base.connection.execute(sql)
    result = result_sql[0]
  end


  def difference_in_completed_years (d1, d2)
    a = d2.year - d1.year
    a = a - 1 if (
    d1.month >  d2.month or
      (d1.month >= d2.month and d1.day > d2.day)
    )
    a
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
    render_403 if @project && !@project.module_enabled?('report_passport')
  end


end
