#-- encoding: UTF-8

# This file written by BBM
# 25/04/2019

class ControlLevelsController < ApplicationController
  layout 'admin'

  before_action :require_coordinator
  before_action :find_control_level, only: [:edit, :update, :destroy]

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{ControlLevel.table_name}.id",
                    'name' => "#{ControlLevel.table_name}.name",
                    'code' => "#{ControlLevel.table_name}.code",
    }

    sort_init 'id', 'desc'
    sort_update sort_columns

    @control_levels = ControlLevel
                     .order(sort_clause)
                     .page(page_param)
                     .per_page(per_page_param)
  end

  def edit; end

  def new
    @control_level = ControlLevel.new
  end

  def create
    @control_level = ControlLevel.new(permitted_params.control_level)

    update_roles_from_params

    if @control_level.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    update_roles_from_params
    if @control_level.update_attributes(permitted_params.control_level)
      flash[:notice] = l(:notice_successful_update)
      redirect_to control_levels_path()
    else
      render action: 'edit'
    end
  end

  def update_roles_from_params
    attrs = permitted_params.control_level_roles

    if attrs.include? :roles
      role_ids = attrs.delete(:roles).map(&:to_i).select { |i| i > 0 }
      @control_level.assign_roles(role_ids)
    end
    @control_level
  end

  def destroy
    @control_level.destroy
    redirect_to action: 'index'
    return
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_control_levels)
    else
      ActionController::Base.helpers.link_to(t(:label_control_levels), control_levels_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_control_level
    @control_level = ControlLevel.find(params[:id])
  end
end
