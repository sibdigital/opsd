class TargetsController < ApplicationController
#  menu_item :targets

  include PaginationHelper
  include Concerns::Layout

  default_search_scope :targets

  before_action :disable_api
  before_action :find_targets_object, except: %i[new create index update destroy]
  before_action :find_project_from_association, except: %i[new create index]
  before_action :find_project, only: %i[new create update destroy]
  before_action :authorize, except: [:index]
  before_action :find_optional_project, only: [:index]
  accept_key_auth :index

  def index
    scope = @project ? @project.targets : Target.all

   end

  current_menu_item :index do
    :targets
  end

  def show

  end

  def new
    @target = Target.new(project: @project)
  end

  def create
    @target = Target.new(project: @project)
    @target.attributes = permitted_params.target
    if @target.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to controller: '/targets', action: 'index', project_id: @project
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    @target.attributes = permitted_params.target
    if @target.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'show', id: @target
    else
      render action: 'edit'
    end
  end

  def destroy
    @target.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: 'index', project_id: @project
  end

  private

  def find_targets_object
    @target = @object = Target.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
