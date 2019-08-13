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
      @organization_parent = Organization.find(@parent_id)
    end
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

  def edit

  end


  def new
    @organization = Organization.new
    @organization.org_type = params[:org_type]
  end

  def create
    @organization = Organization.new(permitted_params.organization)

    if @organization.save
      flash[:notice] = l(:notice_successful_create)
      if @organization.org_type == Enumeration.find_by(name: "Орган исполнительной власти").id
        redirect_to org_settings_iogv_path
      elsif @organization.org_type == Enumeration.find_by(name: "Муниципальное образование").id
        redirect_to org_settings_municipalities_path
      elsif @organization.org_type == Enumeration.find_by(name: "Контрагент").id
        redirect_to org_settings_counterparties_path
      else
        redirect_to org_settings_positions_path
      end
    else
      render action: 'new'
    end
  end

  def update
    if @organization.update_attributes(permitted_params.organization)
      flash[:notice] = l(:notice_successful_update)
      if @organization.org_type == Enumeration.find_by(name: "Орган исполнительной власти").id
        redirect_to org_settings_iogv_path
      elsif @organization.org_type == Enumeration.find_by(name: "Муниципальное образование").id
        redirect_to org_settings_municipalities_path
      elsif @organization.org_type == Enumeration.find_by(name: "Контрагент").id
        redirect_to org_settings_counterparties_path
      else
        redirect_to org_settings_positions_path
      end
    else
      render action: 'edit'
    end
  end

  def destroy
    @organization.destroy
    if @organization.org_type == Enumeration.find_by(name: "Орган исполнительной власти").id
      redirect_to org_settings_iogv_path
    elsif @organization.org_type == Enumeration.find_by(name: "Муниципальное образование").id
      redirect_to org_settings_municipalities_path
    elsif @organization.org_type == Enumeration.find_by(name: "Контрагент").id
      redirect_to org_settings_counterparties_path
    else
      redirect_to org_settings_positions_path
    end

  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_organizations)
    else
      if @organization.org_type == Enumeration.find_by(name: "Орган исполнительной власти").id
        ActionController::Base.helpers.link_to(t(:label_iogv), org_settings_iogv_path)
      elsif @organization.org_type == Enumeration.find_by(name: "Муниципальное образование").id
        ActionController::Base.helpers.link_to(t(:label_municipalities), org_settings_municipalities_path)
      elsif @organization.org_type == Enumeration.find_by(name: "Контрагент").id
        ActionController::Base.helpers.link_to(t(:label_counterparties), org_settings_counterparties_path)
      else
        ActionController::Base.helpers.link_to(t(:label_positions), org_settings_positions_path)
      end
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
  end

  # def find_project
  #   @project = Project.find(params[:project_id])
  # rescue ActiveRecord::RecordNotFound
  #   render_404
  # end

