class MeetingProtocolsController < ApplicationController
  include SortHelper
  before_action :find_meeting, only:[:create]

  def create
    if params[:meeting_protocol][:assigned_to_id].present? and params[:meeting_protocol][:assigned_to_id] == "0"
      @meeting_protocols=[]
      data = permitted_params.meeting_protocol
      MeetingParticipant.joins("JOIN users ON meeting_participants.user_id = users.id" )
        .where(meeting_id: @meeting.id, attended: true).each do |p|
        data[:assigned_to_id] = p.user_id
        @meeting_protocols << @meeting.protocols.build(data)
      end
      if @meeting_protocols.each(&:save)
        flash[:notice] = l(:notice_successful_create)
        redirect_back_or_default controller: '/meetings', action: 'show', id: @meeting
      else
        render 'meetings/show'
      end
    else
      meeting_protocol_params = permitted_params.meeting_protocol

      @meeting_protocol = @meeting.protocols.build(meeting_protocol_params)

      if @meeting_protocol.save
        flash[:notice] = l(:notice_successful_create)
        redirect_back_or_default controller: '/meetings', action: 'show', id: @meeting
      else
        render 'meetings/show'
      end
    end
  end

  def destroy
    @meeting_protocol = MeetingProtocol.find(params[:id])
    @meeting_protocol.destroy

    redirect_back_or_default controller: '/meetings', action: 'show', id: @meeting_protocol.meeting_contents_id
    nil
  end

  def update
    if params[:protocol_action].present? and params[:protocol_action] == "complete"
      @meeting_protocol = MeetingProtocol.find(params[:id])
      @meeting_protocol.completed = true
      @meeting_protocol.completed_at = Date.today
    elsif params[:protocol_action].present? and params[:protocol_action] == "change"
      @meeting_protocol = MeetingProtocol.find(params[:id])
      @meeting_protocol.update(permitted_params.meeting_protocol)
    end
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


