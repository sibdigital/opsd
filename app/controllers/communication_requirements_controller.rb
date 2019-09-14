# by zbd
class CommunicationRequirementsController < ApplicationController
  before_action :find_project
  before_action :find_com_requirement, only: [:edit, :update, :destroy]

  def new
    @com_req = CommunicationRequirement.new(project_id: @project.id)
  end

  def create
    @com_req = CommunicationRequirement.create(permitted_params.communication_requirement)

    if @com_req.save!
      flash[:notice] = l(:notice_successful_create)
      redirect_to #
    else
      render action: 'new'
    end
  end

  def edit

  end

  def update
    if @com_req.update_attributes(permitted_params.communication_requirement)
      flash[:notice] = l(:notice_successful_update)
      redirect_to #project_stakeholders_path #(project_id: @project.identifier)
    else
      render action: 'edit'
    end
  end

  def destroy
    @com_req.destroy
    redirect_to #project_stakeholders_path
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

end
