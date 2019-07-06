class StagesController < ApplicationController
  menu_item :stages

  before_action :find_project
  before_action :authorize
  before_action :set_current_user
  before_action :check_valid_tab
  before_action :get_tab_stages

  def show
    #params['id'] = params['project_id']
    @tab = params[:tab]
    @id = params['project_id']
  end

  private

  def stages_init
    @altered_project = @project
  end

  def stages_control
    @remaining_days = Setting.remaining_count_days.to_i
    now = Date.today + @remaining_days

    if !@user.nil?
      @works = []
      @exp_works = []
      if (MemberRole.joins("INNER JOIN members ON member_roles.member_id=members.id INNER JOIN roles ON member_roles.role_id=roles.id")
            .where("position in (?) and user_id = ?", [6, 7, 9, 10, 11, 12, 14, 15, 16], @user.id)
            .count > 0) or (@user.admin)
        @works = WorkPackage.visible(@user).where("due_date >= :d1 and due_date <= :d2 and done_ratio<100",{d1: Date.today, d2: now})
        @exp_works = WorkPackage.visible(@user).where('(due_date < ?) and (done_ratio<100)', Date.today)
      else
        @works = WorkPackage.with_assigned(@user).where("due_date >= :d1 and due_date <= :d2 and done_ratio<100",{d1: Date.today, d2: now})
        @exp_works = WorkPackage.with_assigned(@user).where('(due_date < ?) and (done_ratio<100)', Date.today)
      end
    end

  end

  # def default_breadcrumb
  #   if action_name == 'index'
  #     t(:label_stages)
  #   else
  #     ActionController::Base.helpers.link_to(t(:label_stages), stages_project_path(@project))
  #   end
  # end
  #
  # def show_local_breadcrumb
  #   false
  # end

  def check_valid_tab
    @selected_tab =
      if params[:tab]
        helpers.stages_tabs.detect { |t| t[:name] == params[:tab] }
      else
        helpers.stages_tabs.first
      end

    unless @selected_tab
      render_404
    end
  end

  def find_project
    #params['id'] = params['project_id']
    if !params[:id].nil?
      @project = Project.find(params[:id])
    else
      @project = Project.find(params[:project_id])
      params['id'] = params['project_id']
    end
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  ##
  # Only load the needed elements for the current tab
  def get_tab_stages
    callback = "stages_#{@selected_tab[:name]}"
    if respond_to?(callback, true)
      send(callback)
    end
  end

  def set_current_user
    @user = current_user
  end

end
