# zbd

class TypedTargetsController < ApplicationController
layout 'admin'

before_action :require_coordinator
before_action :find_typed_target, only: [:edit, :update, :destroy]

helper :sort
include SortHelper
include PaginationHelper
include ::IconsHelper
include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{TypedTarget.table_name}.id",
                    'name' => "#{TypedTarget.table_name}.name",
                    'status' => "#{TypedTarget.table_name}.status_id",
                    'type' => "#{TypedTarget.table_name}.type_id",
                    'basic_value' => "#{TypedTarget.table_name}.basic_value",
                    'plan_value' => "#{TypedTarget.table_name}.plan_value"
    }

    sort_init 'id', 'desc'
    sort_update sort_columns

    @typed_targets = TypedTarget
                     .order(sort_clause)
                     .page(page_param)
                     .per_page(per_page_param)
  end

  def edit
    if params[:tab].blank?
      redirect_to tab: :properties
    else
      @typed_target = TypedTarget
                      .find(params[:id])
      @tab = params[:tab]
    end
  end
  
  def new
    @typed_target = TypedTarget.new
  end
  
  def create
    @typed_target = TypedTarget.new(permitted_params.typed_target)
  
    if @typed_target.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end
  
  def update
    if @typed_target.update_attributes(permitted_params.typed_target)
      flash[:notice] = l(:notice_successful_update)
      redirect_to typed_targets_path()
    else
      render action: 'edit'
    end
  end
  
  def destroy
    @typed_target.destroy
    redirect_to action: 'index'
    return
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_typed_targets)
    else
      ActionController::Base.helpers.link_to(t(:label_typed_targets), typed_targets_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_typed_target
    @typed_target = TypedTarget.find(params[:id])
  end
end
