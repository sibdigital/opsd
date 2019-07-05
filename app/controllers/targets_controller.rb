class TargetsController < ApplicationController
  menu_item :targets
  before_action :find_optional_project
  include TargetsHelper

  def index
    @tab = params[:tab]

  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_targets)
    else
      ActionController::Base.helpers.link_to(t(:label_targets), project_targets_path)
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
