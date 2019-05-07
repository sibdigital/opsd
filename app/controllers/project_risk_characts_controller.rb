#-- encoding: UTF-8
# This file written by BBM
# 29/04/2019
#

class ProjectRiskCharactsController < ApplicationController
  menu_item :project_risks
  before_action :find_optional_project, :verify_project_risks_module_activated
  before_action :find_risk_charact, only: [:edit, :update, :destroy]

  def edit; end

  def new
    risk_ch_class = risk_charact_class(permitted_params.risk_charact_type)
    if risk_ch_class
      @risk_charact = risk_ch_class.new
      @risk_charact.risk_id = params[:risk_id]
    else
      render_400 # bad request
    end
  end

  def create
    risk_ch_params = permitted_params.risk_charact
    type = permitted_params.risk_charact_type
    @risk_charact = Risk.find(params[:risk_id]).risk_characts.build(risk_ch_params)

    if @risk_charact.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to edit_tab_project_project_risk_path(id: @risk_charact.risk_id, project_id: @project.identifier, tab: :risk_characts)
    else
      render action: 'new'
    end
  end

  def update
    risk_ch_params = permitted_params.risk_charact
    type = permitted_params.risk_charact_type
    @risk_charact.type = risk_charact_class(type).try(:name) || @risk_charact.type
    if @risk_charact.update_attributes risk_ch_params
      flash[:notice] = l(:notice_successful_update)
      redirect_to edit_tab_project_project_risk_path(id: @risk_charact.risk_id, project_id: @project.identifier, tab: :risk_characts)
    else
      render action: 'edit'
    end
  end

  def destroy
    @risk_charact.destroy
    redirect_to edit_tab_project_project_risk_path(id: @risk_charact.risk_id, project_id: @project.identifier, tab: :risk_characts)
    #@risk_type = @risk_type.class.all - [@risk_type]
  end

  protected

  def find_risk_charact
    @risk_charact = RiskCharact.find(params[:id])
  end

  def risk_charact_class(type)
    klass = type.to_s.constantize
    raise NameError unless klass.ancestors.include? RiskCharact
    klass
  rescue NameError
    nil
  end

  def default_breadcrumb
    risk = Risk.find(params[:risk_id])
    [ActionController::Base.helpers.link_to(t(:label_project_risks), project_project_risks_path(project_id: @project.identifier)),
    ActionController::Base.helpers.link_to(risk, edit_tab_project_project_risk_path(id: risk.id, project_id: @project.identifier, tab: :risk_characts))]
  end

  def show_local_breadcrumb
    true
  end

  private

  # TODO: см. find_optional_project в ActivitiesController
  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def verify_project_risks_module_activated
    render_403 if @project && !@project.module_enabled?('project_risks')
  end
end
