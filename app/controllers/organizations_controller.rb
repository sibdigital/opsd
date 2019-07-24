#-- encoding: UTF-8
#+-tan 2019.04.25
class OrganizationsController < ApplicationController

  layout 'admin'

  before_action :require_admin
  before_action :find_organization, only: [:edit, :update, :destroy]
  respond_to :html, :json

  protect_from_forgery with: :exception
  include OrgSettingsHelper

  def index;
    @tab = params[:tab]

    @parent_id = 0
    if params[:parent_id] != nil
      @parent_id = params[:parent_id]
    else  @parent_id = 0
    end
    if @parent_id != 0
      @organizarion_parent = Organization.find(@parent_id)
    end

    # @data =
  end

  def choose
    respond_to do |format|
      format.html
    end
  end

  def choose_from_depart
    if request.post?
      select_org_id = 0
      params.select { |i| i.start_with?("ch") }.each do |value|
        if (value[1] == 'on')
          select_org_id = value[0].remove("ch")
        end
      end
      redirect_to (request.referer + "?organization_id=#{select_org_id}").remove('/' + action_name)
    else
      render action: 'choose'
    end
  end

  def edit; end

  def new
    @organization = Organization.new

    @organization.org_type = params[:org_type]
    @parent_id = 0
    if params[:parent_id] != nil
      @parent_id = params[:parent_id]
      else  @parent_id = 0
    end
    @organization.parent_id = @parent_id
    if @organization.parent_id != 0
       @organization_parent = Organization.find(@parent_id)
    end
  end

  def create

    @organization = Organization.new(permitted_params.organization)

    if @organization.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to org_settings_path
    else
      render action: 'new'
    end
  end

  def update
    if @organization.update_attributes(permitted_params.organization)
      flash[:notice] = l(:notice_successful_update)
      redirect_to org_settings_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @organization.destroy
    redirect_to org_settings_path

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
    if @organization.parent_id != 0
       @organization_parent = Organization.find(@organization.parent_id)
    end
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
