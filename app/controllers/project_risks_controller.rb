#-- encoding: UTF-8
# This file written by BBM
# 23/04/2019
class ProjectRisksController < ApplicationController
  include Concerns::Layout

  before_action :find_project, only: [:index]

  def index
    respond_to do |format|
      format.html do
        render layout: layout_non_or_no_menu
      end
    end
  end

  def edit; end

  def new
    @project_risk = TypedRisk.new
  end

  def create
    @project_risk = TypedRisk.new(permitted_params.project_risk)

    if @project_risk.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @project_risk.update_attributes(permitted_params.project_risk)
      flash[:notice] = l(:notice_successful_update)
      redirect_to typed_risks_path()
    else
      render action: 'edit'
    end
  end

  def destroy
    @project_risk.destroy
    redirect_to action: 'index'
    return
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_project_risks)
    else
      ActionController::Base.helpers.link_to(t(:label_project_risks), typed_risks_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_project_risk
    @project_risk = ProjectRisk.find(params[:id])
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
