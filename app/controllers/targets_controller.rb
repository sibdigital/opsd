class TargetsController < ApplicationController
#  menu_item :targets

  default_search_scope :targets



  before_action :find_optional_project, :verify_targets_module_activated
  before_action :find_target, only: [:edit, :update, :destroy]

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{Target.table_name}.id",
                    'name' => "#{Target.table_name}.name",
                    'status' => "#{Target.table_name}.status_id",
                    'type' => "#{Target.table_name}.type_id"
    }

    sort_init 'id', 'desc'
    sort_update sort_columns

    @parent_id = parent_id_param

    @targets = @project.targets.where(parent_id: @parent_id)
                       .order(sort_clause)
                       .page(page_param)
                       .per_page(per_page_param)
   end

  def edit
    if params[:tab].blank?
      redirect_to tab: :properties
    else
      @tab = params[:tab]
    end
  end

  def new
    @target = Target.new

    if params[:parent_id] != nil
      @parent_id = params[:parent_id]
    else
      @parent_id = 0
    end
    @target.parent_id = @parent_id
  end

  def create
    @target = @project.targets.create(permitted_params.target)

    if @target.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @target.update_attributes(permitted_params.target)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_targets_path()
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

  # TODO: см. find_optional_project в ActivitiesController
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
