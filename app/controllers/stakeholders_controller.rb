class StakeholdersController < ApplicationController
  before_action :find_optional_project

  def index
    @project = Project.find(params[:project_id])
    @org_stakeholders = StakeholderOrganization.where(project_id: @project.id).all
    @user_stakeholders = StakeholderUser.where(project_id: @project.id).order(:organization_id).all
    @outer_stakeholders = StakeholderOuter.where(project_id: @project.id).all
  end

  def default_breadcrumb
    if action_name == 'index'
      t(:label_stakeholders)
    else
      #ActionController::Base.helpers.link_to(t(:label_stakeholders), stakeholders_path)
    end
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

end
