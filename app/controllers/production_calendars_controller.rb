class ProductionCalendarsController < ApplicationController
  layout 'admin'
  before_action :require_coordinator
  before_action :find_production_calendar, only: [:edit, :update, :destroy]
  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index

    if Setting.find_by(name: 'work_days').value
      setting=Setting.find_by(name: 'work_days')
      setting.value = "12345"
      setting.save
    end
    sort_columns = {'id' => "#{ProductionCalendar.table_name}.id",
                    'day_type'=>"#{ProductionCalendar.table_name}.day_type",
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
  def refresh
    # render action: 'index'
    array = Array::[](params[:day1], params[:day2], params[:day3], params[:day4], params[:day5], params[:day6], params[:day7])
    setting_work_days = ""
    array.each_with_index do |item, index|
      if item === "1"
        setting_work_days += (index + 1).to_s
      end
    end
    setting=Setting.find_by(name: 'work_days')
    # (Setting.where(id: 119).map {|u| [u.value]}).join = value of entity
    setting.value = setting_work_days.to_i
    setting.save
    redirect_to action: 'index'
  end
  def create
    if(params[:commit] === "Применить")
      refresh
    else
      @production_calendar = ProductionCalendar.new(permitted_params.production_calendar)
      @production_calendar.year = @production_calendar.date.year
      if @production_calendar.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to action: 'index'
      else
        render action: 'new'
      end
    end
  end

  def show_local_breadcrumb
    true
  end
end
