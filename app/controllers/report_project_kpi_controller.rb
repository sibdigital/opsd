class ReportProjectKpiController < ApplicationController
  before_action :find_optional_project
  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
