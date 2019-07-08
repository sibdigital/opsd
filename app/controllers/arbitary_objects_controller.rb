class ArbitaryObjectsController < ApplicationController

  default_search_scope :arbitary_objects

  before_action :find_optional_project, :verify_arbitary_objects_module_activated
  before_action :find_arbitary_object, only: [:edit, :update, :destroy]

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{ArbitaryObject.table_name}.id",
                    'name' => "#{ArbitaryObject.table_name}.name",
                    'type_id' => "#{ArbitaryObject.table_name}.type_id"
    }

    sort_init 'id', 'desc'
    sort_update sort_columns

    @arbitary_objects = @project.arbitary_objects
                       .order(sort_clause)
                       .page(page_param)
                       .per_page(per_page_param)

   end

  def edit

  end

  def new
    @arbitary_object = ArbitaryObject.new
  end




  def create
    @arbitary_object = @project.arbitary_objects.create(permitted_params.arbitary_object)

    if @arbitary_object.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @arbitary_object.update_attributes(permitted_params.arbitary_object)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_arbitary_objects_path()
    else
      render action: 'edit'
    end
  end

  def destroy
    @arbitary_object.destroy
    redirect_to action: 'index'
    nil
  end

  protected

  def find_arbitary_object
    @arbitary_object = @project.arbitary_objects.find(params[:id])
  end

  def default_breadcrumb
    if action_name == 'index'
      t(:label_arbitary_objects)
    else
      ActionController::Base.helpers.link_to(t(:label_targets), project_arbitary_objects_path(project_id: @project.identifier))
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

  def verify_arbitary_objects_module_activated
    render_403 if @project && !@project.module_enabled?('arbitary_objects')
  end


  def remove_quotations(str)
    if str.start_with?('"')
      str = str.slice(1..-1)
    end
    if str.end_with?('"')
      str = str.slice(0..-2)
    end
  end

end
