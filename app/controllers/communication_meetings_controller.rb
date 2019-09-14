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
                      'name' => "#{CommunicationRequirement.table_name}.contract_date" #,
      #                 'contract_num' => "#{Contract.table_name}.contract_num",
      #                 'contract_subject' => "#{Contract.table_name}.contract_subject",
      #                 'eis_href' => "#{Contract.table_name}.eis_href",
      #                 'price' => "#{Contract.table_name}.price",
      #                 'executor' => "#{Contract.table_name}.executor"
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
                      'name' => "#{CommunicationMeeting.table_name}.contract_date" #,
                      #                 'contract_num' => "#{Contract.table_name}.contract_num",
                      #                 'contract_subject' => "#{Contract.table_name}.contract_subject",
                      #                 'eis_href' => "#{Contract.table_name}.eis_href",
                      #                 'price' => "#{Contract.table_name}.price",
                      #                 'executor' => "#{Contract.table_name}.executor"
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
