# by zbd
class CommunicationMeetingMembersController < ApplicationController
  before_action :find_project
  before_action :find_com_meeting_member, only: [:edit, :update, :destroy]
  before_action :prepare_params, only: [:create, :update]

  include SortHelper
  include PaginationHelper

  # def index
    # sort_columns = {'id' => "#{CommunicationMeetingMember.table_name}.id",
    #                 'stakeholder' => "#{CommunicationMeetingMember.table_name}.stakeholder"
    # }
    # sort_init 'id', 'asc'
    # sort_update sort_columns
    # @com_meeting_member = CommunicationMeetingMember
    #              .where(project_id: @project.id)
    #              .order(sort_clause)
    #              .page(page_param)
    #              .per_page(per_page_param)
  # end

  # def new
  #   @com_meeting_member = CommunicationMeetingMember.new(project_id: @project.id, communication_meeting_id: params[:communication_meeting_id])
  # end

  def create
    @com_meeting_member = CommunicationMeetingMember.create(permitted_params.communication_meeting_member)

    if @com_meeting_member.save!
      flash[:notice] = l(:notice_successful_create)
      redirect_to edit_project_communication_meeting_path(project_id: @project.id, id: params[:communication_meeting_id], tab: :meet)
    else
      render action: 'new'
    end
  end

  def edit

  end

  def update
    if @com_meeting_member.update_attributes(permitted_params.communication_meeting_member)
      flash[:notice] = l(:notice_successful_update)
      redirect_to edit_project_communication_meeting_path(project_id: @project.id, id: params[:communication_meeting_id], tab: :meet)
    else
      render action: 'edit'
    end
  end

  def destroy
    @com_meeting_member.destroy
    redirect_to edit_project_communication_meeting_path(project_id: @project.id, id: params[:communication_meeting_id], tab: :meet)
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

  def find_com_meeting_member
    @com_meeting_member = CommunicationMeetingMember.find(params[:id])
  end

  def prepare_params
    tmp = params['communication_meeting_member']['stakeholder_id'].to_s
    tmp = tmp.split(':')
    params['communication_meeting_member']['stakeholder_type'] = tmp[0]
    params['communication_meeting_member']['stakeholder_id'] = tmp[1]
  end
end
