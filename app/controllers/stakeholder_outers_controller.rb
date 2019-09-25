class StakeholderOutersController < ApplicationController
  before_action :find_project
  before_action :find_stakeholder_outer, only: [:edit, :update, :destroy]

  def new
    @stakeholder = StakeholderOuter.new
    @stakeholder.project_id = @project.id
  end

  def edit
  end

  def create
    @stakeholder = StakeholderOuter.create(permitted_params.stakeholder_outer)

    if @stakeholder.save!
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_stakeholders_path #(project_id: @stakeholder.project_id)
    else
      render action: 'new'
    end
  end

  def update
    if @stakeholder.update_attributes(permitted_params.stakeholder_outer)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_stakeholders_path #(project_id: @project.identifier)
    else
      render action: 'edit'
    end
  end

  def destroy
    @stakeholder.destroy
    redirect_to project_stakeholders_path
    nil
  end

  def default_breadcrumb
    if action_name == 'index'
      t(:label_stakeholder_outer)
    else
      ActionController::Base.helpers.link_to(t(:label_stakeholder_outer), project_stakeholders_path)
    end
  end

  def show_local_breadcrumb
    true
  end


  private

  def find_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_stakeholder_outer
    @stakeholder = StakeholderOuter.find(params[:id])
  end

end
