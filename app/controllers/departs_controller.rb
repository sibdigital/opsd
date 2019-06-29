#-- encoding: UTF-8
#+-tan 2019.04.25
class DepartsController < ApplicationController

  layout 'admin'

  before_action :require_admin
  before_action :find_depart, only: [:edit, :update, :destroy]
  protect_from_forgery with: :exception

  def index; end

  def edit; end

  def new
    @depart = Depart.new
  end

  def create
    @depart = Depart.new(permitted_params.depart)

    if @depart.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to controller: 'org_settings', action: 'index', tab:'departs'
    else
      render action: 'new'
    end
  end

  def update
    if @depart.update_attributes(permitted_params.depart)
      flash[:notice] = l(:notice_successful_update)
      redirect_to controller: 'org_settings', action: 'index', tab:'departs'
    else
      render action: 'edit'
    end
  end

  def destroy
    @depart.destroy
    redirect_to controller: 'org_settings', action: 'index', tab:'departs'
    return
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_departs)
    else
      ActionController::Base.helpers.link_to(t(:label_departs), departs_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_depart
    @depart = Depart.find(params[:id])
  end

  def respond_modal_with(*args, &blk)
    options = args.extract_options!
    options[:responder] = ModalResponder
    respond_with *args, options, &blk
  end

  private

  # def find_project
  #   @project = Project.find(params[:project_id])
  # rescue ActiveRecord::RecordNotFound
  #   render_404
  # end
end
