#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

class ProjectRisksController < ApplicationController
  menu_item :project_risks
  before_action :find_optional_project, :verify_project_risks_module_activated
  before_action :find_project_risk, only: [:edit, :update, :destroy]

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{ProjectRisk.table_name}.id",
                    'name' => "#{ProjectRisk.table_name}.name",
                    'owner' => "#{ProjectRisk.table_name}.owner_id",
                    'possibility' => "#{ProjectRisk.table_name}.possibility_id",
                    'importance' => "#{ProjectRisk.table_name}.importance_id"
    }

    sort_init 'id', 'desc'
    sort_update sort_columns

    @project_risks = @project.project_risks
                       .order(sort_clause)
                       .page(page_param)
                       .per_page(per_page_param)
  end

  def edit
    if params[:tab].blank?
      redirect_to tab: :properties
    else
      @tab = params[:tab]
    end
  end

  def new
    @project_risk = ProjectRisk.new
  end

  def choose_typed
    if request.post? && params[:choose_typed]
      permitted_params.choose_typed.to_h.each do |name, values|
        if values.is_a?(Array)
          # remove blank values in array settings
          values.delete_if(&:blank?)
        end
        ProjectRisk.transaction do
          values.each do |value|
            project_risk = copy_typed_to_project value.to_i
            project_risk.save
            # TODO: project_risk_charact - скопировать из потомков typed-a и сохранить
          end
          flash[:notice] = l(:notice_successful_create)
        rescue Exception => e
          flash[:error] = e.message
          raise ActiveRecord::Rollback
        end
      end
      redirect_to action: 'index'
    end
  end


  def create
    @project_risk = @project.project_risks.create(permitted_params.project_risk)

    if @project_risk.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @project_risk.update_attributes(permitted_params.project_risk)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_project_risks_path()
    else
      render action: 'edit'
    end
  end

  def destroy
    @project_risk.destroy
    redirect_to action: 'index'
    nil
  end

  protected

  def find_project_risk
    @project_risk = @project.project_risks.find(params[:id])
  end

  def default_breadcrumb
    if action_name == 'index'
      t(:label_project_risks)
    else
      ActionController::Base.helpers.link_to(t(:label_project_risks), project_project_risks_path(project_id: @project.identifier))
    end
  end

  def show_local_breadcrumb
    true
  end

  private

  # TODO: см. find_optional_project в ActivitiesController
  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def verify_project_risks_module_activated
    render_403 if @project && !@project.module_enabled?('project_risks')
  end

  def copy_typed_to_project(id)
    typed_risk = TypedRisk.find(id)
    project_risk = @project.project_risks.build
    project_risk.name = typed_risk.name
    project_risk.description = typed_risk.description
    project_risk.possibility = typed_risk.possibility
    project_risk.importance = typed_risk.importance
    project_risk.owner_id = typed_risk.owner_id
    project_risk.is_possibility = typed_risk.is_possibility
    project_risk.color = typed_risk.color
    typed_risk.risk_characts.each do |typed_risk_charact|
      project_risk_charact = project_risk.risk_characts.build
      project_risk_charact.name = typed_risk_charact.name
      project_risk_charact.description = typed_risk_charact.description
      project_risk_charact.type = typed_risk_charact.type
      project_risk_charact.position = typed_risk_charact.position
    end
    project_risk
  end

  def remove_quotations(str)
    if str.start_with?('"')
      str = str.slice(1..-1)
    end
    if str.end_with?('"')
      str = str.slice(0..-2)
    end
  end
end
