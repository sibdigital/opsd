class StrategicMapController < ApplicationController
  layout 'admin'
  before_action :require_coordinator

  def index
  end

  def get_list
    list = NationalProject.where(id: params["national_id"]).map { |n| [n.name, n.parent_id, n.id, n.type] }
    federals = NationalProject.where(parent_id: params["national_id"]).map { |f| [f.name, f.parent_id, f.id, f.type] }
    regionals = Array.new
    federals.each do |federal|
      regionals = regionals + Project.where(federal_project_id: federal[2]).map { |p| [p.name, p.federal_project_id, p.id, "Regional"] }
    end
    first_lvl = Array.new
    regionals.each do |regional|
      WorkPackage.where(project_id: regional[2]).each do |wp|
        if wp.parent == nil
          first_lvl = first_lvl + [[wp.subject, wp.project_id, wp.id, Project.find(regional[2]).identifier]]
        end
      end
    end
    list = list + federals + regionals + first_lvl
  render json: list
  end
end
