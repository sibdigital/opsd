#-- encoding: UTF-8
#+-tan 2019.04.25
class OrganizationsController < ApplicationController

  layout 'admin'

  before_action :require_admin
  before_action :find_organization, only: [:edit, :update, :destroy]
  respond_to :html, :json

  protect_from_forgery with: :exception

  def index;
  end

  def select
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit; end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(permitted_params.organization)

    if @organization.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to controller: 'org_settings', action: 'index', tab:'organizations'
    else
      render action: 'new'
    end
  end

  def update
    if @organization.update_attributes(permitted_params.organization)
      flash[:notice] = l(:notice_successful_update)
      redirect_to controller: 'org_settings', action: 'index', tab:'organizations'
    else
      render action: 'edit'
    end
  end

  def destroy
    @organization.destroy
    redirect_to controller: 'org_settings', action: 'index', tab:'organizations'
    return
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_organizations)
    else
      ActionController::Base.helpers.link_to(t(:label_organizations), organizations_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_organization
    @organization = Organization.find(params[:id])
  end

  private

  def respond_modal_with(*args, &blk)
    options = args.extract_options!
    options[:responder] = ModalResponder
    respond_with *args, options, &blk
  end

  # def find_project
  #   @project = Project.find(params[:project_id])
  # rescue ActiveRecord::RecordNotFound
  #   render_404
  # end
end
