class StatisticsController < ApplicationController
  menu_item :activity
  before_action :find_optional_project
  accept_key_auth :index
  helper :sort
  include SortHelper
  include CustomFieldsHelper
  include PaginationHelper
  def index
    sort_columns = {'journable_type' => "#{Journal.table_name}.journable_type", 'journable_id' => "#{Journal.table_name}.journable_id"}
    sort_init 'id', 'asc'
    sort_update sort_columns

    @statistics =  Journal.where("journable_type = ? OR journable_type = ? OR journable_type = ? OR journable_type = ?", "WorkPackage", "Document", "Message", "Project").order(sort_clause)
                     .page(page_param)
                     .per_page(per_page_param)
  end

  private

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
