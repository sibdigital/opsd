# by zbd
class CommunicationMeetingsController < ApplicationController
  before_action :find_project
  before_action :find_com_meeting, only: [:edit, :update, :destroy]

  include SortHelper
  include PaginationHelper

  def index
    if params[:tab].blank?
      @tab = "req"
    else
      @tab = params[:tab]
    end

    case @tab
    when 'req'
      sort_columns = {'id' => "#{CommunicationRequirement.table_name}.id",
                      'name' => "#{CommunicationRequirement.table_name}.name",
                       'stakeholder' => "#{Contract.table_name}.stakeholder",
                       'period' => "#{Contract.table_name}.period"
      }
      sort_init 'id', 'asc'
      sort_update sort_columns
      @com_req = CommunicationRequirement
                    .where(project_id: @project.id)
                    .order(sort_clause)
                    .page(page_param)
                    .per_page(per_page_param)

    when 'meet'
      sort_columns = {'id' => "#{CommunicationMeeting.table_name}.id",
                      'name' => "#{CommunicationMeeting.table_name}.name",
                      'theme' => "#{CommunicationMeeting.table_name}.theme",
                      'kind' => "#{CommunicationMeeting.table_name}.kind",
                      'sposob' => "#{CommunicationMeeting.table_name}.sposob",
                      'period' => "#{CommunicationMeeting.table_name}.period",
                      'user_id' => "#{CommunicationMeeting.table_name}.user_id"
      }
      sort_init 'id', 'asc'
      sort_update sort_columns
      @com_meeting = CommunicationMeeting
                   .where(project_id: @project.id)
                   .order(sort_clause)
                   .page(page_param)
                   .per_page(per_page_param)
    end

  end

  def new
    @com_meeting = CommunicationMeeting.new(project_id: @project.id)
  end

  def create
    @com_meeting = CommunicationMeeting.create(permitted_params.communication_meeting)

    if @com_meeting.save!
      flash[:notice] = l(:notice_add_member_values)
      redirect_to edit_project_communication_meeting_path(project_id: @project.id, id: @com_meeting.id, tab: :meet)
    else
      render action: 'new'
    end
  end

  def edit
    @com_meeting_members = CommunicationMeetingMember.where(project_id: @project.id, communication_meeting_id: params[:id]).all
  end

  def update
    if @com_meeting.update_attributes(permitted_params.communication_meeting)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_communication_meetings_path(project_id: @project.id, tab: :meet)
    else
      render action: 'edit'
    end
  end

  def destroy
    @com_meeting.destroy
    redirect_to project_communication_meetings_path(project_id: @project.id, tab: :meet)
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
