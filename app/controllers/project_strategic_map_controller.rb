class ProjectStrategicMapController < ApplicationController
  menu_item :project_strategic_map
  before_action :find_project
  def index

  end

  def get_project
    # el = [name, parent_id, id+type, type] for eg ["Культура", nil, "4National", National]
    if @national_project.nil? && @federal_project.nil?
      list = [[@project.name, nil, @project.id.to_s+"Regional", "Regional"]]
    elsif @federal_project.nil?
      list = [[@national_project.name, nil, @national_project.id.to_s+@national_project.type, @national_project.type]]
      list = list + [[@project.name, @national_project.id.to_s+@national_project.type, @project.id.to_s+"Regional", "Regional"]]
    else
      list = [[@national_project.name, nil, @national_project.id.to_s+@national_project.type, @national_project.type]]
      list = list + [[@federal_project.name, @national_project.id.to_s+@national_project.type, @federal_project.id.to_s+@federal_project.type, @federal_project.type]]
      list = list + [[@project.name, @federal_project.id.to_s+@federal_project.type, @project.id.to_s+"Regional", "Regional"]]
    end
    list = list + @project.work_packages.map {|wp| [wp.subject, wp.project_id.to_s+"Regional",wp.id.to_s+@project.identifier,@project.identifier ]}
    render json: list
  end

  def find_project
    @project = Project.find(params[:project_id])
    @national_project = @project.national_project
    @federal_project = @project.federal_project
  rescue ActiveRecord::RecordNotFound
    render plain: "Could not find project ##{params[:id]}.", status: 404
  end
end
