
class ProductionCalendarController < ApplicationController
  layout 'admin'
  before_action :require_admin
  # before_action :find_production_calendars, only: [:edit, :update, :destroy]
  # helper :sort
  # include SortHelper
  # include PaginationHelper
  # include ::IconsHelper
  # include ::ColorsHelper

  def index
    # @production_calendar = ProductionCalendar.all
    # @production_calendar = ProductionCalendar.order(Arel.sql('date'))
     respond_to do |format|
       format.html do render html: @production_calendar end
       format.xml  do render xml: @production_calendar end

     end
    # sort_columns = {'id' => "#{ProductionCalendar.table_name}.id",
    #                 'type' => "#{ProductionCalendar.table_name}.type",
    #                 'date' => "#{ProductionCalendar.table_name}.date",
    #                 'isFirst' => "#{ProductionCalendar.table_name}.is_first",
    #                 'hours' => "#{ProductionCalendar.table_name}.hours"
    # }
    # sort_init 'id', 'desc'
    # sort_update sort_columns
    #
    # @production_calendar = ProductionCalendar
    #                  .order(sort_clause)
    #                  .page(page_param)
    #                  .per_page(per_page_param)
  end
  #
  # def edit
  #   if params[:tab].blank?
  #     redirect_to tab: :properties
  #   else
  #     @production_calendar = ProductionCalendar
  #                     .find(params[:id])
  #     @tab = params[:tab]
  #   end
  # end
  #
  # def new
  #   @production_calendar = ProductionCalendar.new
  # end
  #
  # def create
  #   @production_calendar = ProductionCalendar.new(permitted_params.production_calendar)
  #
  #   if  @production_calendar.save
  #     flash[:notice] = l(:notice_successful_create)
  #     redirect_to action: 'index'
  #   else
  #     render action: 'new'
  #   end
  # end
  #
  # def update
  #   if @production_calendar.update_attributes(permitted_params.production_calendar)
  #     flash[:notice] = l(:notice_successful_update)
  #     redirect_to production_calendar_path()
  #   else
  #     render action: 'edit'
  #   end
  # end
  #
  # def destroy
  #   @production_calendar.destroy
  #   redirect_to action: 'index'
  #   return
  # end
  #
  # protected
  #
  # def default_breadcrumb
  #   if action_name == 'index'
  #     t(:label_production_calendar)
  #   else
  #     ActionController::Base.helpers.link_to(t(:label_production_calendar), production_calendar_path)
  #   end
  # end
  #
  # def show_local_breadcrumb
  #   true
  # end
  #
  # def find_typed_risk
  #   @production_calendar = ProductionCalendar.find(params[:id])
  # end
end
