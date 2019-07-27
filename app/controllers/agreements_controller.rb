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
    workbook = RubyXL::Parser.parse(template_path)
    workbook.calc_pr.full_calc_on_load = true

    sheet = workbook['Титульный лист']

    sheet[22][11].change_contents(@project.name)


    sheet.sheet_data[27][5].change_fill('0ba53d') #  0ba53d -зеленый
    sheet.sheet_data[27][9].change_fill('ff0000') #  ff0000 -красный
    sheet.sheet_data[27][13].change_fill('ffd800') #  ffd800 -желтый
    sheet.sheet_data[27][17].change_fill('ffd800') #  ffd800 -желтый
    sheet.sheet_data[27][21].change_fill('ffd800') #  ffd800 -желтый


    @ready_project_progress_report_path = File.absolute_path('.') +'/'+'public/reports/project_progress_report_out.xlsx'
    workbook.write(@ready_project_progress_report_path)
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
