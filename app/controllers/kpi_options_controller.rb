class KpiOptionsController < ApplicationController
  layout 'admin'

  menu_item :kpi_options
  before_action :find_kpi_option, only: [:edit, :update, :destroy, :show]

  def index
    @kpi_options = KeyPerformanceIndicator.all
  end

  def new
    @kpi_option = KeyPerformanceIndicator.new
  end

  def create
    @kpi_option = KeyPerformanceIndicator.new(permitted_params.kpi_option)

    if @kpi_option.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to kpi_cases_path(@kpi_option.id)
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @kpi_option.update_attributes(permitted_params.kpi_option)
      flash[:notice] = l(:notice_successful_update)
      redirect_to kpi_cases_path(@kpi_option.id)
    else
      render action: 'edit'
    end
  end

  def destroy
    @kpi_option.destroy
    redirect_to action: 'index'
    return
  end

  protected

  def show_local_breadcrumb
    true
  end

  def default_breadcrumb
    if action_name == 'index'
      t(:label_kpi_option)
    else
      ActionController::Base.helpers.link_to(t(:label_kpi_option), kpi_options_path)
    end
  end

  def find_kpi_option
    @kpi_option = KeyPerformanceIndicator.find(params[:id])
  end
end
