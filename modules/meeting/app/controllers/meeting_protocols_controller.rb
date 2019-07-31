class MeetingProtocolsController < ApplicationController
  include SortHelper

=begin
  def index
    sort_columns = {'id' => "#{MeetingProtocol.table_name}.id",
                    'assigned_to_id' => "#{MeetingProtocol.table_name}.assigned_to_id",
                    'text' => "#{MeetingProtocol.table_name}.text",
                    'due_date' => "#{MeetingProtocol.table_name}.due_date"
    }

    sort_init 'id', 'desc'
    sort_update sort_columns

    @meeting_protocols = @project.arbitary_objects
                          .order(sort_clause)
                          .page(page_param)
                          .per_page(per_page_param)

  end
=end

  def update
    #target_exec_params = permitted_params.target_execution_value
    puts "in MeetingProtocolsController#update"
=begin

    if @target_execution_value.update_attributes target_exec_params
      flash[:notice] = l(:notice_successful_update)
      redirect_to edit_project_target_path(id: @target_execution_value.target_id, tab: :target_execution_values)
    else
      #render action: 'edit'
      redirect_to edit_project_target_path(id: @target_execution_value.target_id, tab: :target_execution_values)
    end

=end

  end

  def create
    #target_exec_params = permitted_params.target_execution_value
    meeting_protocol_params = permitted_params.meeting_protocol
    @meeting_protocol = MeetingContent.find(params[:meeting_contents_id]).protocols.build(meeting_protocol_params)

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
end


