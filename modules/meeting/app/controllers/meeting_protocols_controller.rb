class MeetingProtocolsController < ApplicationController
  include SortHelper
  before_action :find_meeting, only:[:create]

  def create
    meeting_protocol_params = permitted_params.meeting_protocol

    @meeting_protocol = @meeting.protocols.build(meeting_protocol_params)

    if @meeting_protocol.save
      flash[:notice] = l(:notice_successful_create)
      redirect_back_or_default controller: '/meetings', action: 'show', id: @meeting
    else
      render 'meetings/show'
    end
  end

  def destroy
    @meeting_protocol = MeetingProtocol.find(params[:id])
    @meeting_protocol.destroy

    redirect_back_or_default controller: '/meetings', action: 'show', id: @meeting_protocol.meeting_contents_id
    nil
  end

  def update
    @meeting_protocol = MeetingProtocol.find(params[:id])
    @meeting_protocol.completed = true

    if @meeting_protocol.save
      flash[:notice] = l(:notice_successful_create)
      redirect_back_or_default controller: '/meetings', action: 'show', id: @meeting_protocol.meeting_contents_id
    else
      render 'meetings/show'
    end
  end


  def find_meeting
    @meeting = Meeting
                 .includes([:project, :author, { participants: :user }, :agenda, :minutes])
                 .find(params[:meeting_contents_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end


