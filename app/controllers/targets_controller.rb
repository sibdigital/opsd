class TargetsController < ApplicationController
  #layout 'base'
  default_search_scope :targets

  before_action :find_optional_project, :verify_targets_module_activated
  before_action :find_target, only: [:edit, :update, :destroy]
  before_action :authorize

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper
  include TargetsHelper

  def index
    sort_columns = {'id' => "#{Target.table_name}.id",
                    'name' => "#{Target.table_name}.name",
                    'status' => "#{Target.table_name}.status_id",
                    'type' => "#{Target.table_name}.type_id"
    }

    sort_init [['parent_id', 'asc'],['id', 'asc']]
    sort_update sort_columns

    @parent_id = parent_id_param

    @targets = @project.targets
                       .order(sort_clause)
                       .page(page_param)
                       .per_page(per_page_param)
  end

  def edit
    @targets_arr = [['', 0]]
    @targets_arr += Target.where('project_id = ? and id <> ?', @project.id, @target.id).map {|u| [u.name, u.id]}
  end

  def new
    @target = Target.new

    @target.project_id = find_project_by_project_id.id
    if params[:parent_id] != nil
      @parent_id = params[:parent_id]
    else
      @parent_id = 0
    end

    @target.parent_id = @parent_id
    if @target.parent_id != 0
      @target_parent = Target.find(@parent_id)
    end

    @targets_arr = [['', 0]]
    @targets_arr += Target.where('project_id = ?', @project.id).map {|u| [u.name, u.id]}

  end

  def create
    @target = @project.targets.create(permitted_params.target)

    if @target.save
      flash[:notice] = l(:notice_add_target_values)
      redirect_to edit_project_target_path(id: @target.id) #action: 'edit'

    else
      render action: 'new'
    end
  end

  def update
    if @target.update_attributes(permitted_params.target)
      flash[:notice] = l(:notice_successful_update)
      #redirect_to project_targets_path()
      redirect_to edit_project_target_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @target.destroy
    redirect_to action: 'index'
    nil
  end

  protected

  def find_target
    @target = @project.targets.find(params[:id])
    if @target.parent_id != 0
      @target_parent = Target.find(@target.parent_id)
    end
  end

  def default_breadcrumb
    if action_name == 'index'
      t(:label_targets)
    else
      ActionController::Base.helpers.link_to(t(:label_targets), project_targets_path(project_id: @project.identifier))
    end
  end

  def show_local_breadcrumb
    true
  end

  private

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def verify_targets_module_activated
    render_403 if @project && !@project.module_enabled?('targets')
  end

  def remove_quotations(str)
    if str.start_with?('"')
      str = str.slice(1..-1)
    end
    if str.end_with?('"')
      str = str.slice(0..-2)
    end
  end

  def parent_id_param
    params.fetch(:parent_id){0}
  end

end
