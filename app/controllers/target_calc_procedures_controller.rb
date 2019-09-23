class TargetCalcProceduresController < ApplicationController
  before_action :find_optional_project
  before_action :find_calc_procedure, only: [:edit, :update, :destroy]

  menu_item :target_calc_procedure
  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{TargetCalcProcedure.table_name}.id",
                    'name' => "#{TargetCalcProcedure.table_name}.name"
    }

    sort_init [['id', 'asc']]
    sort_update sort_columns
    @calc_procedures = @project.target_calc_procedures.order(sort_clause)
                         .page(page_param)
                         .per_page(per_page_param)
  end
  def new
    @calc_procedure = TargetCalcProcedure.new
    @calc_procedure.project_id = @project.id
  end
  def edit

  end
  def destroy
    @calc_procedure.destroy
    redirect_to action: 'index'
    nil
  end
  def create
    @calc_procedure = TargetCalcProcedure.create(permitted_params.target_calc_procedure)
    if @calc_procedure.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end
  def update
    if @calc_procedure.update_attributes(permitted_params.target_calc_procedure)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_target_calc_procedures_path()
    else
      render action: 'edit'
    end
  end
  def find_calc_procedure
    @calc_procedure = @project.target_calc_procedures.find(params[:id])
  end
  def default_breadcrumb
    if action_name == 'index'
      t(:label_target_calc_procedures)
    else
      ActionController::Base.helpers.link_to(t(:label_target_calc_procedures), project_target_calc_procedures_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
