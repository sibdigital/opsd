class GeneralMeetingsController < ApplicationController
  before_action :find_meetings, except: [:index, :new, :create]
  include WatchersHelper
  include PaginationHelper
  def index
    tomorrows_meetings_count = GeneralMeeting.from_tomorrow.count
    @page_of_today = 1 + tomorrows_meetings_count / per_page_param

    page = params['page'] ?
             page_param :
             @page_of_today

    @general_meetings = GeneralMeeting.with_users_by_date
                  .page(page)
                  .per_page(per_page_param)

    @meetings_by_start_year_month_date = Meeting.group_by_time(@general_meetings)
  end

  def show
  end

  def new
    @general_meeting = GeneralMeeting.new
  end

  def create
    # @general_meeting.participants.clear # Start with a clean set of participants
    # @general_meeting.participants_attributes = @converted_params.delete(:participants_attributes)
    # @general_meeting.attributes = @converted_params
    # if params[:copied_from_meeting_id].present? && params[:copied_meeting_agenda_text].present?
    #   @general_meeting.agenda = MeetingAgenda.new(
    #     text: params[:copied_meeting_agenda_text],
    #     comment: "Copied from Meeting ##{params[:copied_from_meeting_id]}")
    #   @general_meeting.agenda.author = User.current
    # end
    @general_meeting = GeneralMeeting.create(permitted_params.general_meeting)
    @general_meeting.author = User.current
    if @general_meeting.save
      text = l(:notice_successful_create)
      if User.current.time_zone.nil?
        link = l(:notice_timezone_missing, zone: Time.zone)
        text += " #{view_context.link_to(link, { controller: '/my', action: :account }, class: 'link_to_profile')}"
      end
      flash[:notice] = text.html_safe

      redirect_to action: 'show', id: @general_meeting
    else
      render template: 'general_meetings/new'
    end
  end

  def edit
  end

  def update
    # @general_meeting.author = User.current
    if @general_meeting.update_attributes(permitted_params.general_meeting)
      text = l(:notice_successful_create)
      if User.current.time_zone.nil?
        link = l(:notice_timezone_missing, zone: Time.zone)
        text += " #{view_context.link_to(link, { controller: '/my', action: :account }, class: 'link_to_profile')}"
      end
      flash[:notice] = text.html_safe

      redirect_to action: 'show', id: @general_meeting
    else
      render template: 'general_meetings/edit'
    end
  end

  def destroy
    @general_meeting.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: 'index'
  end

  def find_meetings
    @general_meeting = GeneralMeeting.find(params[:id])
  end
end
