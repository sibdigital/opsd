class StrategicMapController < ApplicationController
  layout 'admin'
  before_action :require_coordinator

  def index
  end

  def get_list
    list = NationalProject.where(id: params["national_id"]).map { |n| [n.name, n.parent_id, n.id.to_s+n.type, n.type] }
    federals = NationalProject.where(parent_id: params["national_id"]).map { |f| [f.name, f.parent_id.to_s+"National", f.id.to_s+f.type, f.type] }
    regionals = Array.new
    regionals = regionals + Project.visible.where(federal_project_id: nil, national_project_id: params["national_id"]).map { |p| [p.name, p.national_project_id.to_s+"National", p.id, "Regional"] }
    # regionals = regionals + Project.visible.where(federal_project_id: nil, national_project_id: params["national_id"]).map { |p| [p.name, "0Federal", p.id, "Regional"] }
    federals.each do |federal|
      regionals = regionals + Project.visible.where(federal_project_id: federal[2]).map { |p| [p.name, p.federal_project_id.to_s+"Federal", p.id, "Regional"] }
    end
    first_lvl = Array.new
    regionals.each do |regional|
      WorkPackage.where(project_id: regional[2]).each do |wp|
        if wp.parent == nil
          first_lvl = first_lvl + [[wp.subject, wp.project_id.to_s+"Regional", wp.id.to_s+Project.find(regional[2]).identifier, Project.find(regional[2]).identifier]]
        end
      end
      regional[2]=regional[2].to_s+"Regional"
    end
    # federals = federals + [["Проекты межнационального уровня", params["national_id"]+"National", "0Federal", "Federal" ]]
    list = list + federals + regionals + first_lvl
  render json: list
  end
end
