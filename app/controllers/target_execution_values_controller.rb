#-- encoding: UTF-8
# This file written by BBM
# 29/04/2019
#

class TargetExecutionValuesController < ApplicationController
  layout 'admin'

  before_action :find_target_execution_value, only: [:edit, :update, :destroy]

  def edit; end

  def new

      @target_execution_value = TargetExecutionValue.new
      @target_execution_value.target_id = params[:target_id]
  end

  def create
    target_exec_params = permitted_params.target_execution_values
    @target_execution_value = Target.find(params[:target_id]).target_execution_values.build(target_exec_params)

    if @target_execution_value.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to edit_tab_target_path(id: @target_execution_value.target_id, tab: :target_execution_values)
    else
      render action: 'new'
    end
  end

  def update
    target_exec_params = permitted_params.target_execution_values


    if @@target_execution_value.update_attributes target_exec_params
      flash[:notice] = l(:notice_successful_update)
      redirect_to edit_tab_target_path(id: @target_execution_value.target_id, tab: :target_execution_values)
    else
      render action: 'edit'
    end
  end

  def destroy
    @target_execution_value.destroy
    redirect_to edit_tab_target_path(id: @target_execution_value.target_id, tab: :target_execution_values)
  end

  protected

  def default_breadcrumb
    target = Target.find(params[:target_id])
    [ActionController::Base.helpers.link_to(t(:label_targets), targets_path),
     ActionController::Base.helpers.link_to(risk, edit_tab_target_path(id: target.id, tab: :target_execution_values))]
  end

  def show_local_breadcrumb
    true
  end

  def find_target_execution_value
    @target_execution_value = TargetExecutionValue.find(params[:id])
  end

end
