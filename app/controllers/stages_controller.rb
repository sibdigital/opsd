class StagesController < ApplicationController
  # menu_item :stages

  before_action :find_project
  before_action :authorize
  before_action :set_current_user
  # before_action :check_valid_tab
  # before_action :get_tab_stages

  def show
    @tab = params[:tab]
    @id = params['project_id']
  end

  def init
    @button_visibility = check_button_visibility
    @id = params['project_id']
    params['id'] = params['project_id']
    @altered_project = @project
  end

  def cancel_init
    @project.project_status_id = ProjectStatus.where(name: I18n.t(:default_project_status_not_start)).first.id
    @project.save
    @project.project_approve_status_id = ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_init)).first.id
    @project.save
    redirect_to action: 'init'
  end

  def proceed_init
    if User.current.project_head? @project
      @project.project_approve_status_id = ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_approve_project_head)).first.id
      @project.save
    elsif User.current.project_office_coordinator? @project
      @project.project_approve_status_id = ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_agreed_project_office_coordinator)).first.id
      @project.save
    elsif User.current.project_office_manager? @project
      @project.project_approve_status_id = ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_agreed_project_office_manager)).first.id
      @project.save
    elsif User.current.project_curator? @project
      @project.project_approve_status_id = ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_approve_curator)).first.id
      @project.save
    elsif User.current.project_activity_coordinator? @project
      @project.project_approve_status_id = ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_approve_glava)).first.id
      @project.project_status_id = ProjectStatus.where(name: I18n.t(:default_project_status_in_work)).first.id
      @project.save
    elsif User.current.project_region_head? @project
      @project.project_status_id = ProjectStatus.where(name: I18n.t(:default_project_status_in_work)).first.id
      @project.save
      @project.project_approve_status_id = ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_approve_glava)).first.id
      @project.save
    end
    redirect_to action: 'init'
  end

  def completion
    @id = params['project_id']
  end

  def analysis
    @id = params['project_id']
  end

  def check_button_visibility
    response = false
    if (User.current.project_head? @project )&& (@project.project_approve_status_id == ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_init)).first.id)
      response = true
    elsif (User.current.project_office_coordinator? @project) && (@project.project_approve_status_id == ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_approve_project_head)).first.id)
      response = true
    elsif  (User.current.project_office_manager? @project) && (@project.project_approve_status_id == ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_agreed_project_office_coordinator)).first.id)
      response = true
    elsif  (User.current.project_curator? @project) && (@project.project_approve_status_id == ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_agreed_project_office_manager)).first.id)
      response = true
    elsif  (User.current.project_activity_coordinator? @project) && (@project.project_approve_status_id == ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_approve_curator)).first.id)
      response = true
    elsif  (User.current.project_region_head? @project )&& (@project.project_approve_status_id == ProjectApproveStatus.where(name: I18n.t(:default_project_approve_status_approve_curator)).first.id)
      response = true
    end
    response
  end

  def control
    @id = params['project_id']
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

  def execution
    @id = params['project_id']
  end

  def planning
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

  #+tan
  # def self_redirect
  #   redirect_to :back
  # end
  # -tan

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
    # params['id'] = params['project_id']
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

  def default_breadcrumb
    if action_name == 'show'
      "Этапы"
    # else
    #   ActionController::Base.helpers.link_to("Этапы", project_stages_path)
    end
  end

  def show_local_breadcrumb
    true
  end
end
