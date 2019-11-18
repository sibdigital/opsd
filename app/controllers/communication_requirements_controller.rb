# by zbd
class CommunicationRequirementsController < ApplicationController
  before_action :find_project
  before_action :find_com_requirement, only: [:edit, :update, :destroy]

  include StakeholdersHelper

  def new
    @com_req = CommunicationRequirement.new(project_id: @project.id)

    sth_users, sth_orgs = get_stakeholders(@project.id)
    @stakeholders = []
    sth_users.each do |user|
      @stakeholders.push [user['name'], user['user_id']]
    end

  end

  def create
    @com_req = CommunicationRequirement.create(permitted_params.communication_requirement)

    if @com_req.save!
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_communication_meetings_path(project_id: @project.id, tab: :req)
    else
      render action: 'new'
    end
  end

  def edit
    sth_users, sth_orgs = get_stakeholders(@project.id)
    @stakeholders = []
    sth_users.each do |user|
      @stakeholders.push [user['name'], user['user_id']]
    end
  end

  def update
    if @com_req.update_attributes(permitted_params.communication_requirement)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_communication_meetings_path(project_id: @project.id, tab: :req)
    else
      render action: 'edit'
    end
  end

  def destroy
    @com_req.destroy
    redirect_to project_communication_meetings_path(project_id: @project.id, tab: :req)
    nil
  end

private

  def find_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_com_requirement
    @com_req = CommunicationRequirement.find(params[:id])
  end

  def default_breadcrumb
    if action_name == 'index'
      l(:label_communication_requirements)
    else
      ActionController::Base.helpers.link_to(l(:label_communication_requirements), project_communication_requirements_path)
    end
  end

  def show_local_breadcrumb
    true
  end

end
