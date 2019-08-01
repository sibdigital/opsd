class MeetingProtocolsController < ApplicationController
  include SortHelper

  def create
    #target_exec_params = permitted_params.target_execution_value
    meeting_protocol_params = permitted_params.meeting_protocol
    @meeting_protocol = MeetingContent.find(params[:meeting_contents_id]).protocols.build(meeting_protocol_params)

    #meeting_protocol_executor_params = permitted_params.meeting_protocol_executor
    #@excecutors = @meeting_protocol.participants.build(meeting_protocol_executor_params)

    if @meeting_protocol.save
      flash[:notice] = l(:notice_successful_create)
      #redirect_to edit_project_target_path(id: @target_execution_value.target_id, tab: :target_execution_values)
      redirect_back_or_default controller: '/meetings', action: 'show', id: @meeting_protocol.meeting_content.meeting_id
    else
      #render action: 'new'
      #edit_project_target_path(id: @target_execution_value.target_id, tab: :target_execution_values)
      render 'meetings/show'
    end
  end

  def destroy
    @meeting_protocol = MeetingProtocol.find(params[:id])
    @meeting_protocol.destroy

    redirect_back_or_default controller: '/meetings', action: 'show', id: @meeting_protocol.meeting_content.meeting_id
    nil
  end

end


