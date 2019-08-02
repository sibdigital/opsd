class HeadPerformanceIndicatorValuesController < ApplicationController
  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{HeadPerformanceIndicatorValue.table_name}.id",
                    'head_performance_indicator_id'=>"#{HeadPerformanceIndicatorValue.table_name}.head_performance_indicator_id",
                    'type'=>"#{HeadPerformanceIndicatorValue.table_name}.type",
                    'year'=>"#{HeadPerformanceIndicatorValue.table_name}.year",
                    'quarter'=>"#{HeadPerformanceIndicatorValue.table_name}.quarter",
                    'month'=>"#{HeadPerformanceIndicatorValue.table_name}.month",
                    'value'=>"#{HeadPerformanceIndicatorValue.table_name}.value"
    }
    sort_init 'id', 'asd'
    sort_update sort_columns
    @values = HeadPerformanceIndicatorValue.order(sort_clause).page(page_param).per_page(per_page_param)
  end

  def new
    @value = HeadPerformanceIndicatorValue.new
  end

  def create
    @value = HeadPerformanceIndicatorValue.new(permitted_params.head_performance_indicator_value)
    @value.type = "Execution"

    #
    @value.month = Date.parse(params["head_performance_indicator_value"]["year"]).month
    @value.quarter = (@value.month/3.0).ceil
    @value.sort_code = (HeadPerformanceIndicator.where(id: @value.head_performance_indicator_id).map{|u| [u.sort_code]}).join
    #

    if @value.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end

  end
end
