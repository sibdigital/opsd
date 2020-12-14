class ProjectColorlightController < ApplicationController
  include Downloadable
  menu_item :project_colorlight
  before_action :find_project, :authorize, only: [:index]

  def index; end

  def create
    find_project
    @ready = Colorlight.create_xlsx(params['type'].to_i, @project)
    send_to_user filepath: @ready
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render plain: "Could not find project ##{params[:id]}.", status: 404
  end
end

