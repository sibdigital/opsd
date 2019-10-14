class KpiCasesController < ApplicationController
  layout 'admin'

  menu_item :kpi_options
  before_action :find_kpi_option
  before_action :find_kpi_case, only: [:edit, :update, :destroy]

  def index
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

  end
end
