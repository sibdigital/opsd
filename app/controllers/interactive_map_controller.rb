class InteractiveMapController < ApplicationController
  def index

  end
  def get_dues

    cp=WorkPackage.where(project_id: params["project_id"], plan_type: :execution)
         .map { |f| [f.subject, f.status.is_closed, f.due_date, f.id, f.assigned_to.firstname, f.assigned_to.lastname, f.raion_id]} #region_id
    cp.each do |f|
      # f={name => f.subject, status => f.status.is_closed, due_date => f.due_date, risk => WorkPackageProblem.where(work_package_id: f.id).map {|p| [p.risk_id]}}
      wpp=WorkPackageProblem.where(work_package_id: f[3]).map { |p| [p.risk_id] }
      f << wpp
    end
    render json: cp
  end
end
