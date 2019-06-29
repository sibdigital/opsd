class StagesController < ApplicationController
  menu_item :stages
  before_action :find_optional_project
  include StagesHelper

  def index
    @tab = params[:tab] || 'StageInitCustomField'

  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_stages)
    else
      ActionController::Base.helpers.link_to(t(:label_stages), project_stages_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
