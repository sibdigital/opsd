class KpiCasesController < ApplicationController
  layout 'admin'

  menu_item :kpi_options
  before_action :find_kpi_option
  before_action :find_kpi_case, only: [:edit, :update, :destroy]

  def index
    @kpi_cases = KeyPerformanceIndicatorCase.where(key_performance_indicator_id: @kpi_option)
  end

  def new
    @kpi_case = KeyPerformanceIndicatorCase.new
  end

  def create
    @kpi_case = KeyPerformanceIndicatorCase.new(permitted_params.kpi_case)
    @kpi_case.key_performance_indicator = @kpi_option
    if @kpi_case.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @kpi_case.update_attributes(permitted_params.kpi_case)
      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'index'
    else
      render action: 'edit'
    end
  end

  def destroy
    @kpi_case.destroy
    redirect_to action: 'index'
    return
  end

  protected

  def show_local_breadcrumb
    true
  end

  def default_breadcrumb
    bread = [ActionController::Base.helpers.link_to(t(:label_kpi_option), kpi_options_path)]
    if action_name == 'index'
      bread << @kpi_option
    else
      bread << ActionController::Base.helpers.link_to(@kpi_option, kpi_cases_path)
    end
    bread
  end

  def find_kpi_option
    @kpi_option = KeyPerformanceIndicator.find(params[:kpi_option_id])
  end

  def find_kpi_case
    @kpi_case = KeyPerformanceIndicatorCase.find(params[:id])
  end
end
