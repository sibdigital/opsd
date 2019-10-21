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
    #+tan
    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end
    #-tan
    @ready_agreement_path = dir_path + '/agreement-out.rtf'

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
                                           INNER JOIN roles r ON  mr.role_id = r.id and r.name ='" +I18n.t(:default_role_project_head)+"' "+
                                          "INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s)
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

  end

  def download_file(file_path)
    send_to_user filepath: file_path
  end

  def generate_agreement_pril_1_2

    template_path = File.absolute_path('.') +'/'+'app/reports/templates/agreement_pril_1_2.xlsx'
    @workbook = RubyXL::Parser.parse(template_path)
    @workbook.calc_pr.full_calc_on_load = true

    generate_pril1_sheet
#    generate_pril2_sheet

    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end

    @ready_agreement_pril_1_2_path = dir_path + '/agreement_pril_1_2_out.xlsx'
    @workbook.write(@ready_agreement_pril_1_2_path)

  end

  def generate_pril1_sheet
    region_name = Setting.find_by(name: 'region_name').nil? ? "" : Setting.find_by(name: 'region_name').value

    if @federal_project.nil?
      federal_project_name = ""
    else
      federal_project_name = @federal_project.name
    end

    if @federal_project.nil? || @federal_project.leader_position.nil?
      leader_position_federal_project = ""
    else
      leader_position_federal_project = @federal_project.leader_position
    end

    userList = User.find_by_sql("  SELECT u.* FROM users u
                                           INNER JOIN members  m ON m.user_id = u.id
                                           INNER JOIN member_roles mr ON  mr.member_id = m.id
                                           INNER JOIN roles r ON  mr.role_id = r.id and r.name ='" +I18n.t(:default_role_project_head)+"' "+
                                   "INNER JOIN projects p ON m.project_id = p.id and p.id = " + @project.id.to_s)
    if userList.empty?
      user = User.new
    else
      user = userList[0]
    end

    position =  Position.find_by(id: user.position_id).present? ? Position.find_by(id: user.position_id).name : ""


    sheet = @workbook['Приложение 1']
    sheet[9][4].change_contents(region_name)
    sheet[10][4].change_contents(federal_project_name)
    sheet[11][4].change_contents(@project.name)
    sheet[10][4].change_text_wrap(true)
    sheet[11][4].change_text_wrap(true)

    sheet[21][1].change_contents(leader_position_federal_project)
    sheet[21][1].change_text_wrap(true)

#    sheet.insert_cell(21, 11, position)
    sheet[21][11].change_contents(position)
    sheet[21][11].change_text_wrap(true)

    count_year = difference_in_completed_years(@project.start_date, @project.due_date)

    for i in 0..count_year
      sheet.insert_cell(14, 10+i, "Значение показателей по годам реализации проекта")
      sheet.insert_cell(15, 10+i, @project.start_date.year+i)
      sheet.insert_cell(16, 10+i, (7+i).to_s)

      sheet.sheet_data[14][10+i].change_border(:top, 'thin')
      sheet.sheet_data[14][10+i].change_border(:left, 'thin')
      sheet.sheet_data[14][10+i].change_border(:right, 'thin')
      sheet.sheet_data[14][10+i].change_border(:bottom, 'thin')

      sheet.sheet_data[15][10+i].change_border(:top, 'thin')
      sheet.sheet_data[15][10+i].change_border(:left, 'thin')
      sheet.sheet_data[15][10+i].change_border(:right, 'thin')
      sheet.sheet_data[15][10+i].change_border(:bottom, 'thin')

      sheet.sheet_data[16][10+i].change_border(:top, 'thin')
      sheet.sheet_data[16][10+i].change_border(:left, 'thin')
      sheet.sheet_data[16][10+i].change_border(:right, 'thin')
      sheet.sheet_data[16][10+i].change_border(:bottom, 'thin')
    end
    sheet.merge_cells(14, 10, 14, 10+count_year)



    id_type_indicator = Enumeration.find_by(name: I18n.t(:default_indicator)).id
    targets = Target.where(project_id: @project.id, type_id: id_type_indicator)

    targets.each_with_index do |target, i|
      sheet.insert_cell(17+i, 0, target.name)
      cell = sheet[17+i][0]
      cell.change_text_wrap(true)

      sheet.insert_cell(17+i, 1, (i+1).to_s)
      sheet.insert_cell(17+i, 2, "")
      sheet.merge_cells(17+i, 1, 17+i, 2)

      measure_unit_name = target.measure_unit.nil? ? "": target.measure_unit.name
      measure_unit_code = target.measure_unit.nil? ? "": target.measure_unit.okei_code
      sheet.insert_cell(17+i, 3, measure_unit_name)
      cell = sheet[17+i][3]
      cell.change_text_wrap(true)

      sheet.insert_cell(17+i, 4, measure_unit_code)
      sheet.insert_cell(17+i, 5, "")
      sheet.insert_cell(17+i, 6, "")
      sheet.merge_cells(17+i, 4, 17+i, 6)

      sheet.insert_cell(17+i, 7, target.basic_value)
      sheet.insert_cell(17+i, 8, "")
      sheet.merge_cells(17+i, 7, 17+i, 8)

      basic_date = target.basic_date.nil? ? "" : target.basic_date.strftime("%d.%m.%Y")
      sheet.insert_cell(17+i, 9, basic_date)

      sheet.sheet_data[17+i][0].change_border(:top, 'thin')
      sheet.sheet_data[17+i][0].change_border(:left, 'thin')
      sheet.sheet_data[17+i][0].change_border(:right, 'thin')
      sheet.sheet_data[17+i][0].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][1].change_border(:top, 'thin')
      sheet.sheet_data[17+i][1].change_border(:left, 'thin')
      sheet.sheet_data[17+i][1].change_border(:right, 'thin')
      sheet.sheet_data[17+i][1].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][2].change_border(:top, 'thin')
      sheet.sheet_data[17+i][2].change_border(:left, 'thin')
      sheet.sheet_data[17+i][2].change_border(:right, 'thin')
      sheet.sheet_data[17+i][2].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][3].change_border(:top, 'thin')
      sheet.sheet_data[17+i][3].change_border(:left, 'thin')
      sheet.sheet_data[17+i][3].change_border(:right, 'thin')
      sheet.sheet_data[17+i][3].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][4].change_border(:top, 'thin')
      sheet.sheet_data[17+i][4].change_border(:left, 'thin')
      sheet.sheet_data[17+i][4].change_border(:right, 'thin')
      sheet.sheet_data[17+i][4].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][5].change_border(:top, 'thin')
      sheet.sheet_data[17+i][5].change_border(:left, 'thin')
      sheet.sheet_data[17+i][5].change_border(:right, 'thin')
      sheet.sheet_data[17+i][5].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][6].change_border(:top, 'thin')
      sheet.sheet_data[17+i][6].change_border(:left, 'thin')
      sheet.sheet_data[17+i][6].change_border(:right, 'thin')
      sheet.sheet_data[17+i][6].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][7].change_border(:top, 'thin')
      sheet.sheet_data[17+i][7].change_border(:left, 'thin')
      sheet.sheet_data[17+i][7].change_border(:right, 'thin')
      sheet.sheet_data[17+i][7].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][8].change_border(:top, 'thin')
      sheet.sheet_data[17+i][8].change_border(:left, 'thin')
      sheet.sheet_data[17+i][8].change_border(:right, 'thin')
      sheet.sheet_data[17+i][8].change_border(:bottom, 'thin')

      sheet.sheet_data[17+i][9].change_border(:top, 'thin')
      sheet.sheet_data[17+i][9].change_border(:left, 'thin')
      sheet.sheet_data[17+i][9].change_border(:right, 'thin')
      sheet.sheet_data[17+i][9].change_border(:bottom, 'thin')

      for j in 0..count_year
        targetValue = PlanFactYearlyTargetValue.find_by(target_id: target.id, year: @project.start_date.year+j)
        sheet.insert_cell(17+i, 10+j, targetValue.target_plan_year_value)
        sheet.sheet_data[17+i][10+j].change_border(:top, 'thin')
        sheet.sheet_data[17+i][10+j].change_border(:left, 'thin')
        sheet.sheet_data[17+i][10+j].change_border(:right, 'thin')
        sheet.sheet_data[17+i][10+j].change_border(:bottom, 'thin')

      end

      sheet.sheet_data[17+i][0].change_vertical_alignment('center')

      sheet.sheet_data[17+i][1].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][1].change_vertical_alignment('center')

      sheet.sheet_data[17+i][2].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][2].change_vertical_alignment('center')

      sheet.sheet_data[17+i][3].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][3].change_vertical_alignment('center')

      sheet.sheet_data[17+i][4].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][4].change_vertical_alignment('center')

      sheet.sheet_data[17+i][5].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][5].change_vertical_alignment('center')

      sheet.sheet_data[17+i][6].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][6].change_vertical_alignment('center')

      sheet.sheet_data[17+i][7].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][7].change_vertical_alignment('center')

      sheet.sheet_data[17+i][8].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][8].change_vertical_alignment('center')

      sheet.sheet_data[17+i][9].change_horizontal_alignment('center')
      sheet.sheet_data[17+i][9].change_vertical_alignment('center')

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
      download_file(@ready_agreement_path)
    end
    if  params[:report_id] == 'agreement_pril_1_2'
      generate_agreement_pril_1_2
      download_file(@ready_agreement_pril_1_2_path)
    end

  end

  def difference_in_completed_years (d1, d2)
    a = d2.year - d1.year
    a = a - 1 if (
    d1.month >  d2.month or
      (d1.month >= d2.month and d1.day > d2.day)
    )
    a
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
