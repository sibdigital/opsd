#-- encoding: UTF-8
# This file written by GLY
# 29/11/2021
#

class TargetRisksController < ApplicationController
  #layout 'admin'
  before_action :find_target_risk, only: [:edit, :update, :destroy]

  def edit; end

  def new
    @target_risk = TargetRisk.new
    @target_risk.target_id = params[:target_id]
    @target_risk.risk_id = params[:risk_id]
    @target_risk.solution_date = params[:solution_date]
    @target_risk.is_solved = params[:is_solved]
    @target = Target.find(params[:target_id])
    @risk = Risk.find(params[:risk_id])
  end

  def create
    @target_risk = TargetRisk.new
    @target_risk.target_id = params[:target_id]
    @target_risk.risk_id = params[:target_risk][:risk]
    @target_risk.solution_date = params[:target_risk][:solution_date]
    @target_risk.is_solved = params[:target_risk][:is_solved]


    if @target_risk.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to edit_project_target_path(id: @target_risk.target_id, tab: :target_risks)
    else
      #render action: 'new'

      if @target_risk.errors.any?
        @target_risk.errors.full_messages.each do |msg|
          flash.now[:error] = msg
          flash[:error] = msg
        end
      end

      #edit_project_target_path(id: @target_execution_value.target_id, flash: 'error')
      redirect_to edit_project_target_path(id: @target_risk.target_id, tab: :target_risks)
    end
  end

  def update
    @target_risk.risk_id = params[:target_risk][:risk]
    @target_risk.solution_date = params[:target_risk][:solution_date]
    @target_risk.is_solved = params[:target_risk][:is_solved]

    if @target_risk.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to edit_project_target_path(id: @target_risk.target_id, tab: :target_risks)
    else
      flash[:error] = 'Обновление не выполнено'
      redirect_to edit_project_target_path(id: @target_risk.target_id, tab: :target_risks)
    end
  end

  def destroy
    @target_risk.destroy
    redirect_to edit_project_target_path(id: @target_risk.target_id, tab: :target_risks)
  end

  protected

  def default_breadcrumb
    target = Target.find(params[:target_id])
    [ActionController::Base.helpers.link_to(t(:label_targets), project_targets_path),
     ActionController::Base.helpers.link_to(target, edit_project_target_path(id: target.id, tab: :target_risks))]
  end

  def show_local_breadcrumb
    true
  end

  def find_target_risk
    @target_risk = TargetRisk.find(params[:id])
  end
end
