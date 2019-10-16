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
    generate_target_indicators_sheet
    generate_target_results_sheet
    generate_members_sheet
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

      sheet.merge_cells(5, 0, 5, 7+count_year)

      sheet.insert_cell(5, 0, "")
      sheet.sheet_data[5][0].change_border(:left, 'thin')

      sheet.insert_cell(5, 7+count_year, "")
      sheet.sheet_data[5][7+count_year].change_border(:right, 'thin')


      id_type_indicator = Enumeration.find_by(name: I18n.t(:default_indicator)).id
      targets = Target.where(project_id: @project.id, type_id: id_type_indicator)

      targets.each_with_index do |target, i|
        sheet.insert_cell(6+i, 0, (i+1).to_s)
        sheet.insert_cell(6+i, 1, target.name)
        cell = sheet[6+i][1]
        cell.change_text_wrap(true)

        type_target = target.is_additional == true ? "дополнительный" : "основной"
        sheet.insert_cell(6+i, 2, type_target)
        sheet.sheet_data[6+i][2].change_horizontal_alignment('center')
        sheet.sheet_data[6+i][2].change_vertical_alignment('center')

        sheet.insert_cell(6+i, 3, target.basic_value)
        sheet.insert_cell(6+i, 4, "")
        sheet.merge_cells(6+i, 3, 6+i, 4)
        sheet.sheet_data[6+i][3].change_horizontal_alignment('center')
        sheet.sheet_data[6+i][3].change_vertical_alignment('center')

        basic_date = target.basic_date.nil? ? "" : target.basic_date.strftime("%d.%m.%Y")
        sheet.insert_cell(6+i, 5, basic_date)
        sheet.insert_cell(6+i, 6, "")
        sheet.merge_cells(6+i, 5, 6+i, 6)
        sheet.sheet_data[6+i][5].change_horizontal_alignment('center')
        sheet.sheet_data[6+i][5].change_vertical_alignment('center')

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

        sheet.sheet_data[6+i][4].change_border(:top, 'thin')
        sheet.sheet_data[6+i][4].change_border(:left, 'thin')
        sheet.sheet_data[6+i][4].change_border(:right, 'thin')
        sheet.sheet_data[6+i][4].change_border(:bottom, 'thin')

        sheet.sheet_data[6+i][5].change_border(:top, 'thin')
        sheet.sheet_data[6+i][5].change_border(:left, 'thin')
        sheet.sheet_data[6+i][5].change_border(:right, 'thin')
        sheet.sheet_data[6+i][5].change_border(:bottom, 'thin')

        sheet.sheet_data[6+i][6].change_border(:top, 'thin')
        sheet.sheet_data[6+i][6].change_border(:left, 'thin')
        sheet.sheet_data[6+i][6].change_border(:right, 'thin')
        sheet.sheet_data[6+i][6].change_border(:bottom, 'thin')

        for j in 0..count_year
          targetValue = PlanFactYearlyTargetValue.find_by(target_id: target.id, year: @project.start_date.year+j)
          sheet.insert_cell(6+i, 7+j, targetValue.target_plan_year_value)
          sheet.sheet_data[6+i][7+j].change_border(:top, 'thin')
          sheet.sheet_data[6+i][7+j].change_border(:left, 'thin')
          sheet.sheet_data[6+i][7+j].change_border(:right, 'thin')
          sheet.sheet_data[6+i][7+j].change_border(:bottom, 'thin')

        end
      end

  end

 def generate_target_results_sheet
   sheet = @workbook['Результаты']

   get_result_target_end_date.each_with_index do |result_target, i|
     punkt = "1. "+(i+1).to_s+"."
     sheet.insert_cell(6+i, 0, punkt)
     name = result_target["name"]
     sheet.insert_cell(6+i, 1, name)
     sheet.insert_cell(6+i, 2, "")
     sheet.insert_cell(6+i, 3, "")
     sheet.insert_cell(6+i, 4, "")
     sheet.insert_cell(6+i, 5, "")
     sheet.merge_cells(6+i, 1, 6+i, 5)
     end_date = result_target["quarter"]+'-й квартал '+ result_target["year"]+ ' года'
     sheet.insert_cell(6+i, 6, end_date)
     sheet.insert_cell(6+i, 7, "")
     sheet.merge_cells(6+i, 6, 6+i, 7)
     cell = sheet[6+i][6]
     cell.change_text_wrap(true)
     sheet.insert_cell(6+i, 8, "")
     sheet.insert_cell(6+i, 9, "")
     sheet.insert_cell(6+i, 10, "")
     sheet.insert_cell(6+i, 11, "")
     sheet.insert_cell(6+i, 12, "")
     sheet.insert_cell(6+i, 13, "")
     sheet.merge_cells(6+i, 8, 6+i, 13)


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

     sheet.sheet_data[6+i][4].change_border(:top, 'thin')
     sheet.sheet_data[6+i][4].change_border(:left, 'thin')
     sheet.sheet_data[6+i][4].change_border(:right, 'thin')
     sheet.sheet_data[6+i][4].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][5].change_border(:top, 'thin')
     sheet.sheet_data[6+i][5].change_border(:left, 'thin')
     sheet.sheet_data[6+i][5].change_border(:right, 'thin')
     sheet.sheet_data[6+i][5].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][6].change_border(:top, 'thin')
     sheet.sheet_data[6+i][6].change_border(:left, 'thin')
     sheet.sheet_data[6+i][6].change_border(:right, 'thin')
     sheet.sheet_data[6+i][6].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][7].change_border(:top, 'thin')
     sheet.sheet_data[6+i][7].change_border(:left, 'thin')
     sheet.sheet_data[6+i][7].change_border(:right, 'thin')
     sheet.sheet_data[6+i][7].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][8].change_border(:top, 'thin')
     sheet.sheet_data[6+i][8].change_border(:left, 'thin')
     sheet.sheet_data[6+i][8].change_border(:right, 'thin')
     sheet.sheet_data[6+i][8].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][9].change_border(:top, 'thin')
     sheet.sheet_data[6+i][9].change_border(:left, 'thin')
     sheet.sheet_data[6+i][9].change_border(:right, 'thin')
     sheet.sheet_data[6+i][9].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][10].change_border(:top, 'thin')
     sheet.sheet_data[6+i][10].change_border(:left, 'thin')
     sheet.sheet_data[6+i][10].change_border(:right, 'thin')
     sheet.sheet_data[6+i][10].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][11].change_border(:top, 'thin')
     sheet.sheet_data[6+i][11].change_border(:left, 'thin')
     sheet.sheet_data[6+i][11].change_border(:right, 'thin')
     sheet.sheet_data[6+i][11].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][12].change_border(:top, 'thin')
     sheet.sheet_data[6+i][12].change_border(:left, 'thin')
     sheet.sheet_data[6+i][12].change_border(:right, 'thin')
     sheet.sheet_data[6+i][12].change_border(:bottom, 'thin')

     sheet.sheet_data[6+i][13].change_border(:top, 'thin')
     sheet.sheet_data[6+i][13].change_border(:left, 'thin')
     sheet.sheet_data[6+i][13].change_border(:right, 'thin')
     sheet.sheet_data[6+i][13].change_border(:bottom, 'thin')

   end
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
      sheet.insert_cell(2+i, 5, "")

      str_ids = (str_ids =="" ? user.id.to_s : str_ids += ", "+user.id.to_s)

      sheet.sheet_data[2+i][0].change_horizontal_alignment('center')
      sheet.sheet_data[2+i][0].change_vertical_alignment('center')

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
      sheet.insert_cell(2+i+countUser, 5, "")

      str_ids += ", "+user.id.to_s

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
      sheet.insert_cell(2+i+countUser, 4, direct_manager)
      sheet.insert_cell(2+i+countUser, 5, "")

      str_ids += ", "+user.id.to_s

      sheet.sheet_data[2+i+countUser][0].change_horizontal_alignment('center')
      sheet.sheet_data[2+i+countUser][0].change_vertical_alignment('center')

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
    sheet.sheet_data[start_position-1][0].change_border(:left, 'thin')
    sheet.sheet_data[start_position-1][5].change_border(:right, 'thin')

    members = get_members(str_ids)
    decriment = 0
    members.each_with_index do |member, i|

      direct_manager = User.find_by(id: member.direct_manager_id)
      direct__manager_fio = direct_manager == nil ? "" : direct_manager.name(:lastname_f_p)


      member_info = get_member_info(member)
      if member_info["role"] == I18n.t(:default_role_glava_regiona) ||
         member_info["role"] == I18n.t(:default_role_project_activity_coordinator) ||
         member_info["role"] == I18n.t(:default_role_project_office_manager)
        decriment += 1
      else
        sheet.insert_cell(start_position+i-decriment, 0, (i-decriment+4).to_s)
        sheet.insert_cell(start_position+i-decriment, 1, member_info["role"])
        sheet.insert_cell(start_position+i-decriment, 2, member.name(:lastname_f_p))
        sheet.insert_cell(start_position+i-decriment, 3, member_info["position"])
        sheet.insert_cell(start_position+i-decriment, 4, direct__manager_fio)
        sheet.insert_cell(start_position+i-decriment, 5, "")

        sheet.sheet_data[start_position+i-decriment][0].change_horizontal_alignment('center')
        sheet.sheet_data[start_position+i-decriment][0].change_vertical_alignment('center')


        sheet.sheet_data[start_position+i-decriment][0].change_border(:top, 'thin')
        sheet.sheet_data[start_position+i-decriment][0].change_border(:left, 'thin')
        sheet.sheet_data[start_position+i-decriment][0].change_border(:right, 'thin')
        sheet.sheet_data[start_position+i-decriment][0].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+i-decriment][1].change_border(:top, 'thin')
        sheet.sheet_data[start_position+i-decriment][1].change_border(:left, 'thin')
        sheet.sheet_data[start_position+i-decriment][1].change_border(:right, 'thin')
        sheet.sheet_data[start_position+i-decriment][1].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+i-decriment][2].change_border(:top, 'thin')
        sheet.sheet_data[start_position+i-decriment][2].change_border(:left, 'thin')
        sheet.sheet_data[start_position+i-decriment][2].change_border(:right, 'thin')
        sheet.sheet_data[start_position+i-decriment][2].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+i-decriment][3].change_border(:top, 'thin')
        sheet.sheet_data[start_position+i-decriment][3].change_border(:left, 'thin')
        sheet.sheet_data[start_position+i-decriment][3].change_border(:right, 'thin')
        sheet.sheet_data[start_position+i-decriment][3].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+i-decriment][4].change_border(:top, 'thin')
        sheet.sheet_data[start_position+i-decriment][4].change_border(:left, 'thin')
        sheet.sheet_data[start_position+i-decriment][4].change_border(:right, 'thin')
        sheet.sheet_data[start_position+i-decriment][4].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+i-decriment][5].change_border(:top, 'thin')
        sheet.sheet_data[start_position+i-decriment][5].change_border(:left, 'thin')
        sheet.sheet_data[start_position+i-decriment][5].change_border(:right, 'thin')
        sheet.sheet_data[start_position+i-decriment][5].change_border(:bottom, 'thin')

      end
    end

    incriment = 0
    decriment_result = 0
    get_result_target.each do |result_target|
      sheet.insert_cell(start_position+members.count-decriment+incriment, 0, result_target.name)
      sheet.insert_cell(start_position+members.count-decriment+incriment, 1, "")
      sheet.insert_cell(start_position+members.count-decriment+incriment, 2, "")
      sheet.insert_cell(start_position+members.count-decriment+incriment, 3, "")
      sheet.insert_cell(start_position+members.count-decriment+incriment, 4, "")
      sheet.insert_cell(start_position+members.count-decriment+incriment, 5, "")
      sheet.merge_cells(start_position+members.count-decriment+incriment, 0, start_position+members.count-decriment+incriment, 5)
      sheet.sheet_data[start_position+members.count-decriment+incriment][0].change_border(:left, 'thin')
      sheet.sheet_data[start_position+members.count-decriment+incriment][5].change_border(:right, 'thin')

      result_members = get_result_member(result_target.id.to_s)

      result_members.each do |result_member|

        sheet.insert_cell(start_position+1+members.count-decriment+incriment, 0, (members.count-decriment+incriment+4-decriment_result).to_s)
        role = result_member["role"]

        sheet.insert_cell(start_position+1+members.count-decriment+incriment, 1, role)
        user_id = result_member["user_id"]
        member = User.find_by(id: user_id)
        direct_manager = User.find_by(id: member.direct_manager_id)
        direct__manager_fio = direct_manager == nil ? "" : direct_manager.name(:lastname_f_p)

        fio = member.name(:lastname_f_p)
        sheet.insert_cell(start_position+1+members.count-decriment+incriment, 2, fio)
        position = result_member["position"]
        sheet.insert_cell(start_position+1+members.count-decriment+incriment, 3, position)
        sheet.insert_cell(start_position+1+members.count-decriment+incriment, 4, direct__manager_fio)
        sheet.insert_cell(start_position+1+members.count-decriment+incriment, 5, "")


        sheet.sheet_data[start_position+1+members.count-decriment+incriment][0].change_horizontal_alignment('center')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][0].change_vertical_alignment('center')

        sheet.sheet_data[start_position+1+members.count-decriment+incriment][0].change_horizontal_alignment('center')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][0].change_vertical_alignment('center')

        sheet.sheet_data[start_position+1+members.count-decriment+incriment][0].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][0].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][0].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][0].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+members.count-decriment+incriment][1].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][1].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][1].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][1].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+members.count-decriment+incriment][2].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][2].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][2].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][2].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+members.count-decriment+incriment][3].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][3].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][3].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][3].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+members.count-decriment+incriment][4].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][4].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][4].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][4].change_border(:bottom, 'thin')

        sheet.sheet_data[start_position+1+members.count-decriment+incriment][5].change_border(:top, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][5].change_border(:left, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][5].change_border(:right, 'thin')
        sheet.sheet_data[start_position+1+members.count-decriment+incriment][5].change_border(:bottom, 'thin')

      end

      incriment += 2
      decriment_result += 1
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
    if targetCalcProcedure.target_id != target_id
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
    sheet.insert_cell(start_index+i, 2, targetCalcProcedure.base_target.name)
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
    sql  = " SELECT u.id as user_id, r.name as role, coalesce(ps.name, '') as position FROM users u
             INNER JOIN members  m ON m.user_id = u.id
             INNER JOIN member_roles mr ON  mr.member_id = m.id
             INNER JOIN roles r ON  mr.role_id = r.id
             LEFT JOIN positions ps ON ps.id = u.position_id
             INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s+
           " WHERE u.id = "+user.id.to_s
    result_sql = ActiveRecord::Base.connection.execute(sql)
    result = result_sql[0]
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

    sql  = " select s.id, s.name,  substring(max(s.union_val),1, 4) as year, substring(max(s.union_val),5, 1) as quarter from (
               select t.id, t.name,  concat(cast(tev.year as varchar), cast(tev.quarter as varchar))as union_val
               FROM targets t
               inner join enumerations e on e.id = t.type_id
               left join target_execution_values tev on tev.target_id = t.id
               where t.is_approve=true and e.name = '"+I18n.t(:default_result)+"' and t.project_id = " + @project.id.to_s+ "
              ) as s
             group by s.id, s.name"

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
    render_403 if @project && !@project.module_enabled?('reports')
  end


end
