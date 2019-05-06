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
      @project_risk = ProjectRisk
                      .find(params[:id])
      @tab = params[:tab]
    end
  end

  def new
    @project_risk = ProjectRisk.new
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
    return
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
end
