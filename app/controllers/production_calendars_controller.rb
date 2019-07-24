
class ProductionCalendarsController < ApplicationController
  layout 'admin'
  before_action :require_admin
  before_action :find_production_calendar, only: [:edit, :update, :destroy]
  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{ProductionCalendar.table_name}.id",
                   'type_of_day'=>"#{ProductionCalendar.table_name}.type",
                   'date'=>"#{ProductionCalendar.table_name}.date",
                   'year'=>"#{ProductionCalendar.table_name}.year"
    }
    sort_init 'id', 'desc'
    sort_update sort_columns
    @production_calendars = ProductionCalendar
                       .order(sort_clause)
                       .page(page_param)
                       .per_page(per_page_param)
     # @production_calendar = ProductionCalendar.all
    # @production_calendar = ProductionCalendar.order(Arel.sql('date'))

  end

  def edit
    if params[:tab].blank?
      redirect_to tab: :properties
    else
      @production_calendar = production_calendar
                      .find(params[:id])
      @tab = params[:tab]
    end
  end

  def new
     #@production_calendar = ProductionCalendar.new
     @calend = ProductionCalendar.new
  end

  def default_breadcrumb
    if action_name == 'index'
      t(:label_production_calendars)
    else
      ActionController::Base.helpers.link_to(:label_production_calendars, production_calendars_path)
    end
  end

  def find_production_calendar
    @production_calendar = ProductionCalendar.find(params[:id])
  end

  def destroy
    @production_calendar.destroy
    redirect_to action: 'index'
    nil
  end

  def update
    if @production_calendar.update_attributes(permitted_params.production_calendar)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_production_calendars_path()
    else
      render action: 'edit'
    end
  end

  def show

  end

  def create
    @production_calendar = ProductionCalendar.new(permitted_params.production_calendar)
    @production_calendar.year = @production_calendar.date.year
    if @production_calendar.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def show_local_breadcrumb
    true
  end
end
