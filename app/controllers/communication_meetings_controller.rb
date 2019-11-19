# by zbd
class CommunicationMeetingsController < ApplicationController
  before_action :find_project
  before_action :find_com_meeting, only: [:edit, :update, :destroy]

  include SortHelper
  include PaginationHelper
  include StakeholdersHelper

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
                      'stakeholder' => "#{CommunicationRequirement.table_name}.stakeholder",
                      'period' => "#{CommunicationRequirement.table_name}.period"
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

      sth_users, sth_orgs = get_stakeholders(@project.id)

      # + add StakeholderOuter
      # sth_outer = StakeholderOuter.where(:project_id => @project.id).all
      # sth_outer.each do |sth|
      #   s = []
      #   s = Hash['user_id'=>sth.id,
      #            'organization_id'=> sth.organization_id,
      #            'name'=> sth.name,
      #            'phone_wrk'=> sth.phone_wrk,
      #            'phone_wrk_add'=> sth.phone_wrk_add,
      #            'phone_mobile'=> sth.phone_mobile,
      #            'mail_add'=> sth.mail_add,
      #            'address'=> sth.address,
      #            'cabinet'=> sth.cabinet]
      #   sth_users.push s
      # end

      @stakeholders = []
      sth_users.each do |user|
        @stakeholders.push [user['name'], user['user_id']]
      end

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
    sth_users, sth_orgs = get_stakeholders(@project.id)
    @stakeholders = []
    sth_users.each do |user|
      @stakeholders.push [user['name'], user['user_id']]
    end
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

  def default_breadcrumb
    if action_name == 'index'
      l(:label_communication_meetings_plural)
    else
      ActionController::Base.helpers.link_to(l(:label_communication_meetings), project_communication_meetings_path)
    end
  end

  def show_local_breadcrumb
    true
  end

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
