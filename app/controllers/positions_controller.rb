#-- encoding: UTF-8
#+-tan 2019.04.25
class PositionsController < ApplicationController

  layout 'admin'

  before_action :require_admin
  before_action :find_position, only: [:edit, :update, :destroy]

  def index; end

  def edit; end

  def new
    @position = Position.new
  end

  def create
    @position = Position.new(permitted_params.position)

    if @position.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to controller: 'org_settings', action: 'index', tab:'positions' #:back #action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @position.update_attributes(permitted_params.position)
      flash[:notice] = l(:notice_successful_update)
      redirect_to controller: 'org_settings', action: 'index', tab:'positions' #:back #action: 'index'
    else
      render action: 'edit'
    end
  end

  def destroy
    @position.destroy
    redirect_to controller: 'org_settings', action: 'index', tab:'positions' #:back #action: 'index'
    return
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_positions)
    else
      ActionController::Base.helpers.link_to(t(:label_positions), positions_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_position
    @position = Position.find(params[:id])
  end

  private

  # def find_project
  #   @project = Project.find(params[:project_id])
  # rescue ActiveRecord::RecordNotFound
  #   render_404
  # end
end
