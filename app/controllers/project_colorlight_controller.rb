class ProjectColorlightController < ApplicationController
  include Downloadable
  menu_item :project_colorlight
  before_action :find_project, :authorize, only: [:index]

  def index; end

  def create
    find_project
    if params[:number] == "1"
      @ready = Colorlight.create_xlsx(params['type'].to_i, @project)
      send_to_user filepath: @ready
    elsif params[:number] == "2"
      url = Setting[:jopsd_url] + '/jopsd/generate_light_report/xlsx/params?typeId=' + params[:type] + "&projectId=" + @project.id.to_s
      redirect_to url
    end
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render plain: "Could not find project ##{params[:id]}.", status: 404
  end
end

