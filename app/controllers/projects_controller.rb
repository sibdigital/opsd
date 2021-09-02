#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

class ProjectsController < ApplicationController
  menu_item :overview
  menu_item :roadmap, only: :roadmap
  before_action :disable_api, except: :level_list
  before_action :find_project, except: [:index, :level_list, :new, :create]
  before_action :authorize, only: [
    :show, :edit, :update, :modules, :types, :custom_fields
  ]
  before_action :authorize_global, only: [:new, :create]
  before_action :require_admin, only: [:archive, :unarchive, :destroy, :destroy_info]
  before_action :jump_to_project_menu_item, only: :show
  before_action :load_project_settings, only: :settings
  before_action :toggle_due_date, only: [:update]
  #tmd
  before_action :format_number, only: [:create, :update]

  accept_key_auth :index, :level_list, :show, :create, :update, :destroy

  include SortHelper
  include PaginationHelper
  include CustomFieldsHelper
  include QueriesHelper
  include RepositoriesHelper
  include ProjectsHelper

  # Lists visible projects
  def index
    @projects_view = :projects_angular
    # query = load_query
    # set_sorting(query)
    #
    # unless query.valid?
    #   flash[:error] = query.errors.full_messages
    # end
    #
    # @projects = load_projects query
    # @custom_fields = ProjectCustomField.visible(User.current)
    #
    # respond_to do |format|
    #   format.atom do
    #     head(:gone)
    #   end
    #   format.html do
    #     render layout: 'no_menu'
    #   end
    # end
  end

  current_menu_item :index do
    :list_projects
  end

  def new
    assign_default_create_variables

    render layout: 'no_menu'
  end

  current_menu_item :new do
    :new_project
  end

  def create
    assign_default_create_variables

    if validate_parent_id && @project.save
      @project.set_allowed_parent!(params['project']['parent_id']) if params['project'].has_key?('parent_id')
      add_current_user_to_project_if_not_admin(@project)

      #zbd(
      add_global_users_to_project(@project)
      #)



      respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_create)
          Member.where(project_id: @project.id).each do |member|
            if member != User.current
            Alert.create_pop_up_alert(@project, "Created", User.current, member.user)
            end
          end
          set_project_address
          #ban(
          deliver_mail_to_members
          #)
          redirect_work_packages_or_overview
        end
      end
    else
      respond_to do |format|
        format.html { render action: 'new', layout: 'no_menu' }
      end
    end
  end

  # Show @project
  def show
    @users_by_role = @project.users_by_role
    @subprojects = @project.children.visible
    @news = @project.news.limit(5).includes(:author, :project).order("#{News.table_name}.created_on DESC")
    @types = @project.rolled_up_types

    cond = @project.project_condition(Setting.display_subprojects_work_packages?)

    @open_issues_by_type = WorkPackage
                           .visible.group(:type)
                           .includes(:project, :status, :type)
                           .where(["(#{cond}) AND #{Status.table_name}.is_closed=?", false])
                           .references(:projects, :statuses, :types)
                           .count
    @total_issues_by_type = WorkPackage
                            .visible.group(:type)
                            .includes(:project, :status, :type)
                            .where(cond)
                            .references(:projects, :statuses, :types)
                            .count

    respond_to do |format|
      format.html
    end
  end

  def update
    @altered_project = Project.find(@project.id)
    #ban(
    @old_status = @project.get_project_status.id
    @old_start_date = @project.start_date.to_s
    @old_due_date = @project.due_date.to_s
    #)
    @project.address_id.nil? ? set_project_address : Address.find(@project.address_id).update_attribute(:address, params[:project][:address_id])
    @altered_project.attributes = permitted_params.project
    if validate_parent_id && @altered_project.save
      if params['project'].has_key?('parent_id')
        @altered_project.set_allowed_parent!(params['project']['parent_id'])
      end
      flash[:notice] = l(:notice_successful_update)

      begin
        Member.where(project_id: @altered_project.id).each do |member|
          if member != User.current
          Alert.create_pop_up_alert(@altered_project, "Changed", User.current, member.user)
            end
        end
        #ban(
        recip = @project.recipients
        if (Setting.is_strong_notified_event('project_changed'))
          recip = @project.all_recipients
        end
        if Setting.is_notified_event('project_changed')
          recip.uniq.each do |user|
            if Setting.can_notified_event(user, 'project_changed')
              UserMailer.project_changed(user, @project, User.current, @old_status, @old_start_date, @old_due_date).deliver_later
            end
          end
        end
      rescue Exception => e
        Rails.logger.info(e.message)
      end
      #)
      OpenProject::Notifications.send('project_updated', project: @altered_project)
    end

    redirect_to settings_project_path(@altered_project)
  end



  def update_identifier
    @project.attributes = permitted_params.project

    if @project.save
      flash[:notice] = I18n.t(:notice_successful_update)
      redirect_to settings_project_path(@project)
      OpenProject::Notifications.send('project_renamed', project: @project)
    else
      render action: 'identifier'
    end
  end

  def types
    if UpdateProjectsTypesService.new(@project).call(permitted_params.projects_type_ids)
      flash[:notice] = l('notice_successful_update')
    else
      flash[:error] = @project.errors.full_messages
    end

    redirect_to settings_project_path(@project.identifier, tab: 'types')
  end

  def modules
    @project.enabled_module_names = permitted_params.project[:enabled_module_names]
    # Ensure the project is touched to update its cache key
    @project.touch
    flash[:notice] = I18n.t(:notice_successful_update)
    redirect_to settings_project_path(@project, tab: 'modules')
  end

  def custom_fields
    Project.transaction do
      @project.work_package_custom_field_ids = permitted_params.project[:work_package_custom_field_ids]
      if @project.save
        flash[:notice] = t(:notice_successful_update)
      else
        flash[:error] = t(:notice_project_cannot_update_custom_fields,
                          errors: @project.errors.full_messages.join(', '))
        raise ActiveRecord::Rollback
      end
    end
    redirect_to settings_project_path(@project, tab: 'custom_fields')
  end

  def archive
    projects_url = url_for(controller: '/projects', action: 'index', status: params[:status])
    if @project.archive
      redirect_to projects_url
    else
      flash[:error] = I18n.t(:error_can_not_archive_project)
      redirect_back fallback_location: projects_url
    end
    
    update_demo_project_settings @project, false
  end

  def unarchive
    @project.unarchive if !@project.active?
    redirect_to(url_for(controller: '/projects', action: 'index', status: params[:status]))
    update_demo_project_settings @project, true
  end

  # Delete @project
  def destroy
    service = ::Projects::DeleteProjectService.new(user: current_user, project: @project)
    call = service.call(delayed: true)

    if call.success?
      flash[:notice] = I18n.t('projects.delete.scheduled')
      begin
        destroy_address
        Member.where(project_id: @project.id).each do |member|
          if member != User.current
          Alert.create_pop_up_alert(@project, "Deleted", User.current, member.user)
            end
        end
        #ban(
        @timenow = Time.now.strftime("%d/%m/%Y %H:%M")
        recip = @project.recipients
        if (Setting.is_strong_notified_event('project_changed'))
          recip = @project.all_recipients
        end
        if Setting.is_notified_event('project_deleted')
          recip.uniq.each do |user|
            if Setting.can_notified_event(user, 'project_deleted')
              UserMailer.project_deleted(user, @project, User.current, @timenow).deliver_later
            end
          end
        end
        #)
      rescue Exception => e
        Rails.logger.info(e.message)
      end
    else
      flash[:error] = I18n.t('projects.delete.schedule_failed', errors: call.errors.full_messages.join("\n"))
    end

    redirect_to controller: 'projects', action: 'index'
    update_demo_project_settings @project, false
  end

  def destroy_info
    @project_to_destroy = @project

    hide_project_in_layout
  end

  def level_list
    @projects = Project.project_level_list(Project.visible)

    respond_to do |format|
      format.api
    end
  end

  private

  # tmd
  def format_number
    if params[:project][:invest_amount] != nil
      params[:project][:invest_amount] = params[:project][:invest_amount].gsub(',', '.').to_d.truncate(2)
    end
  end

  # tmd
  def set_project_address
    unless @project.id.nil?
      Address.create(address: params[:project][:address_id], project_id: @project.id).save
      newest_record = Address.last
      @project.update_attribute(:address_id, newest_record[:id])
    end
  end

  # tmd
  def destroy_address
    Address.destroy(@project.address_id)
  end

  def find_optional_project
    return true unless params[:id]
    @project = Project.find(params[:id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_work_packages_or_overview
    return if redirect_to_project_menu_item(@project, :work_packages)

    redirect_to controller: '/projects', action: 'show', id: @project
  end

  def jump_to_project_menu_item
    if params[:jump]
      # try to redirect to the requested menu item
      redirect_to_project_menu_item(@project, params[:jump]) && return
    end
  end

  def hide_project_in_layout
    @project = nil
  end

  def add_current_user_to_project_if_not_admin(project)
    unless User.current.admin?
      r = Role.givable.find_by(id: Setting.new_project_user_role_id.to_i) || Role.givable.first
      m = Member.new do |member|
        member.user = User.current
        member.role_ids = [r].map(&:id) # member.roles = [r] fails, this works
      end
      project.members << m
    end
  end

  def load_query
    @query = ParamsToQueryService.new(Project, current_user).call(params)

    # Set default filter on status no filter is provided.
    if !params[:filters]
      @query.where('status', '=', Project::STATUS_ACTIVE.to_s)
    end

    # Order lft if no order is provided.
    if !params[:sortBy]
      @query.order(lft: :asc)
    end

    @query
  end

  # tmd
  def toggle_due_date
    data_start = Enumeration.where(:type => "ProjectStatus", :name => I18n.t(:default_project_status_in_work)).pluck(:id)
    data_due = Enumeration.where(:type => "ProjectStatus", :name => I18n.t(:default_project_status_completed)).pluck(:id)
    if @project.project_status_id == data_start[0] && @project.fact_start_date == nil
      @project.update_attribute(:fact_start_date, Time.now)
    end

    if @project.project_status_id == data_due[0] && @project.fact_due_date == nil
      @project.update_attribute(:fact_due_date, Time.now)
    end
  end

  def filter_projects_by_permission(projects)
    # Cannot simply use .visible here as it would
    # filter out archived projects for everybody.
    if User.current.admin?
      projects
    else
      projects.visible
    end
  end

  #zbd(
  def filter_projects_by_type(projects)
    if params[:type] == Project::TYPE_TEMPLATE
      projects.templates
    else
      projects.projects
    end
  end
  # )

  def assign_default_create_variables
    @issue_custom_fields = WorkPackageCustomField.order("#{CustomField.table_name}.position")
    @types = ::Type.all
    @project = Project.new
    #@address = @project.build_address
    @project.parent = Project.find(params[:parent_id]) if params[:parent_id]
    @project.attributes = permitted_params.project if params[:project].present?
  end

  protected

  def set_sorting(query)
    orders = query.orders.select(&:valid?).map { |o| [o.attribute.to_s, o.direction.to_s] }

    sort_clear
    sort_init orders
    sort_update orders.map(&:first)
  end

  def load_projects(query)
    projects = query
               .results
               .with_required_storage
               .with_latest_activity
               .includes(:custom_values, :enabled_modules)
               .page(page_param)
               .per_page(per_page_param)

    filter_projects_by_permission projects

    #zbd(
    filter_projects_by_type projects
    # )
  end

  # Validates parent_id param according to user's permissions
  # TODO: move it to Project model in a validation that depends on User.current
  def validate_parent_id
    return true if User.current.admin?
    parent_id = permitted_params.project && params[:project][:parent_id]
    if parent_id || @project.new_record?
      parent = parent_id.blank? ? nil : Project.find_by(id: parent_id.to_i)
      unless @project.allowed_parents.include?(parent)
        @project.errors.add :parent_id, :invalid
        return false
      end
    end
    true
  end

  def update_demo_project_settings(project, value)
    # e.g. when one of the demo projects gets deleted or a archived
    if project.identifier == 'cultura' || project.identifier == 'umts'
      Setting.demo_projects_available = value
    end
  end

  #zbd(
  def add_global_users_to_project(project)
    # найти пользаков с глобальной ролью. Исключаем Координатор от проектного офиса (Сотрудника проектного офиса)
    global_users = []
    PrincipalRole.joins(:role)
      .where('not roles.name like ?', I18n.t(:default_role_project_office_coordinator_global))
      .each { |global_user| global_users.push(global_user.principal_id) }
    global_users = global_users.uniq

    global_users.each do |global_user|
      # найти обычные роли, совпадающие по названию, т.е. без слова (глобальная)
      roles = []
      sql = "select * from roles where type='Role' and name in (
          select trim(replace(r.name, '(глобальная)', '')) from principal_roles pr
          inner join roles r on r.id=pr.role_id
          where principal_id = " + global_user.to_s + ")"
      result = ActiveRecord::Base.connection.execute(sql)
      index = 0
      result.each do |row|
        roles[index] = row['id']
        index += 1
      end

      # добавить в участники проекта с аналогичными ролями без суффикса "(глобальная)"
      if User.current.id != global_user # текущий польз уже добавлен ранее
        m = Member.new do |member|
          member.user = User.find(global_user)
          member.role_ids = roles
        end
        project.members << m
      end
    end
  end

  # переделал метод
  def deliver_mail_to_members
    @project_office_members = []
    roles = []
    Role.where('name in (?)', [I18n.t(:default_role_project_office_manager),
                               I18n.t(:default_role_project_office_coordinator),
                               I18n.t(:default_role_project_office_admin)])
                              .each { |r| roles.push(r)}
    members = Member.joins(:member_roles).where('role_id in (?)', roles)
    members.each do |member|
      if Setting.is_notified_event('project_created')
        user = User.find(member.user_id)
        if user.present? && Setting.can_notified_event(user,'project_created')
          UserMailer.project_created(user, @project, User.current).deliver_later
        end
      end
    end
  end
  # )
end
