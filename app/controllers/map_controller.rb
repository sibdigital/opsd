class MapController < ApplicationController
  menu_item :map
  before_action :find_project, :authorize

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render plain: "Could not find project ##{params[:id]}.", status: 404
  end
end
