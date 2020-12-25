class ProjectInteractiveMapController < ApplicationController
  menu_item :project_interactive_map
  before_action :find_project, :authorize
  def index

  end

  def get_wps
    jarr = WorkPackageIspolnStat.where(project_id: @project.id).where("raion_id > 0")
             .map { |f| [f.subject, f.id, f.raion_id] }
             .each do |u|

      user = User.find_by_id(WorkPackageIspolnStat.find_by_id(u[1]).assigned_to_id)
      user.nil? ? user="Отсутствует" : user=user.fio
      u << user
      if WorkPackageIspolnStat.find_by_id(u[1]).ispolneno
        u << 1
      elsif WorkPackageIspolnStat.find_by_id(u[1]).ne_ispolneno
        u << 2
      elsif WorkPackageIspolnStat.find_by_id(u[1]).est_riski
        u << 3
      elsif  WorkPackageIspolnStat.find_by_id(u[1]).v_rabote
        u << 4
      end

    end
    # jarr <<
    render json: jarr
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render plain: "Could not find project ##{params[:id]}.", status: 404
  end

end
