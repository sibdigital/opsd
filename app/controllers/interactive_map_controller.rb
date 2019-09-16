class InteractiveMapController < ApplicationController
  layout 'admin'
  #before_action :require_coordinator
  before_action :authorize_global, only: [:index]
  def index

  end
  def get_dues
    jarr = WorkPackageIspolnStat.where(project_id: params["project_id"], plan_type: :execution).where("raion_id > 0")
      .map { |f| [f.subject, f.id, f.raion_id] }
      .each do |u|
      user = User.find_by_id(WorkPackageIspolnStat.find_by_id(u[1]).assigned_to_id).name.split(" ", 5)
      user[0]=user[0][0]
      u << user.join(". ")
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
end
