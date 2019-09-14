# by zbd
class CommunicationMeetingsController < ApplicationController
  before_action :find_project
  before_action :find_com_meeting, only: [:edit, :update, :destroy]

  def new
    @com_meeting = CommunicationMeeting.new(project_id: @project.id)
  end

  def create
    @com_meeting = CommunicationMeeting.create(permitted_params.communication_meeting)

    if @com_meeting.save!
      flash[:notice] = l(:notice_successful_create)
      redirect_to #
    else
      render action: 'new'
    end
  end

  def edit

  end

  def update
    if @com_meeting.update_attributes(permitted_params.communication_meeting)
      flash[:notice] = l(:notice_successful_update)
      redirect_to #project_stakeholders_path #(project_id: @project.identifier)
    else
      render action: 'edit'
    end
  end

  def destroy
    @com_meeting.destroy
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

  def find_com_meeting
    @com_meeting = CommunicationMeeting.find(params[:id])
  end

end
