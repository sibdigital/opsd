#-- encoding: UTF-8
#+-tan 2019.04.25

class OrganizationsController < ApplicationController
  layout 'admin'
  menu_item :org_settings

  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  #include ::ColorsHelper
  #include TargetsHelper
  include OrganizationsHelper
  include CustomFilesHelper
  include CounterHelper


  before_action :require_project_admin
  before_action :find_organization, only: [:edit, :update, :destroy]
  before_action :find_org_type
  before_action only: [:create, :update] do
    upload_custom_file("organization", "OrganizationCustomField")
  end

  before_action only: [:destroy] do
    destroy_counter_value("Organization", @organization.id)
  end

  after_action only: [:create, :update] do
    assign_custom_file_name("Organization", @organization.id)
    init_counter_value("Organization", @organization.class.name, @organization.id)
  end

  respond_to :html, :json

  protect_from_forgery with: :exception

  def index
    sort_columns = {'id' => "#{Organization.table_name}.id",
                    'name'=>"#{Organization.table_name}.name"
    }
    sort_init [['parent_id', 'asc'],['id', 'asc']]
    sort_update sort_columns

    #@org_type = nil
    #@organizations = nil

    if @org_type.present?
      @organizations = Organization.where(org_type: @org_type.id).order(sort_clause).page(page_param).per_page(per_page_param)
    end

    @parent_id = parent_id_param

    if @parent_id.to_i != 0
      @organization_parent = Organization.find(@parent_id)
    end
  end

  def new
    @organization = Organization.new
    @organization.org_type = params[:org_type]
  end

  def edit

  end

  def create
    @organization = Organization.new(permitted_params.organization)

    if @organization.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to organizations_path(org_type: @organization.org_type)
    else
      render action: 'new'
    end
  end

  def update
    if @organization.update_attributes(permitted_params.organization)
      flash[:notice] = l(:notice_successful_update)
      redirect_to organizations_path(org_type: @organization.org_type)
    else
      render action: 'edit'
    end
  end

  def show

  end

  def destroy
    @organization.destroy
    redirect_to organizations_path(org_type: @organization.org_type)
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
  
  # def iogv
  #   sort_columns = {'id' => "#{Organization.table_name}.id",
  #                   'name'=>"#{Organization.table_name}.name"
  #   }
  #   sort_init [['parent_id', 'asc'],['id', 'asc']]
  #   sort_update sort_columns
  #   @org_type = OrganizationType.find_by(name: "Орган исполнительной власти").id
  #   @iogv = Organization.where(org_type: @org_type).order(sort_clause).page(page_param).per_page(per_page_param)
  #   # @parent_id = parent_id_param
  #
  #   # if @parent_id.to_i != 0
  #   #   @organization_parent = Organization.find(@parent_id)
  #   # end
  # end
  #
  # def municipalities
  #   sort_columns = {'id' => "#{Organization.table_name}.id",
  #                   'name'=>"#{Organization.table_name}.name"
  #   }
  #   sort_init [['parent_id', 'asc'],['id', 'asc']]
  #   sort_update sort_columns
  #   @org_type = OrganizationType.find_by(name: "Муниципальное образование").id
  #   @municipalities = Organization.where(org_type: @org_type).order(sort_clause).page(page_param).per_page(per_page_param)
  #   # @org_type.to_param
  #   # @parent_id = parent_id_param
  #
  #   # if @parent_id.to_i != 0
  #   #   @organization_parent = Organization.find(@parent_id)
  #   # end
  # end
  #
  # def counterparties
  #   sort_columns = {'id' => "#{Organization.table_name}.id",
  #                   'name'=>"#{Organization.table_name}.name"
  #   }
  #   sort_init [['parent_id', 'asc'],['id', 'asc']]
  #   sort_update sort_columns
  #   @org_type = OrganizationType.find_by(name: "Контрагент").id
  #   @counterparties = Organization.where(org_type: @org_type).order(sort_clause).page(page_param).per_page(per_page_param)
  #   # @parent_id = parent_id_param
  #
  #   # if @parent_id.to_i != 0
  #   #   @organization_parent = Organization.find(@parent_id)
  #   # end
  # end

  def positions
    # @org_type = Enumeration.find_by(name: "Орган исполнительной власти").id
    # @parent_id = parent_id_param
    #
    # if @parent_id.to_i != 0
    #   @organization_parent = Organization.find(@parent_id)
    # end
  end

  #def edit
    # @notifiables = Redmine::Notifiable.all
    # if request.post? && params[:org_settings]
    #   permitted_params.org_settings.to_h.each do |name, value|
    #     if value.is_a?(Array)
    #       # remove blank values in array org_settings
    #       value.delete_if(&:blank?)
    #     elsif value.is_a?(Hash)
    #       value.delete_if { |_, v| v.blank? }
    #     else
    #       value = value.strip
    #     end
    #     Setting[name] = value
    #   end
    #
    #   flash[:notice] = l(:notice_successful_update)
    #   redirect_to action: 'edit', tab: params[:tab]
    # else
    #   @options = {}
    #   @options[:user_format] = User::USER_FORMATS_STRUCTURE.keys.map { |f| [User.current.name(f), f.to_s] }
    #   @deliveries = ActionMailer::Base.perform_deliveries
    #
    #   @guessed_host = request.host_with_port.dup
    #
    #   @custom_style = CustomStyle.current || CustomStyle.new
    # end
  #end
  #
  # def plugin
  #   @plugin = Redmine::Plugin.find(params[:id])
  #   if request.post?
  #     Setting["plugin_#{@plugin.id}"] = params[:settings].permit!.to_h
  #     flash[:notice] = l(:notice_successful_update)
  #     redirect_to action: 'plugin', id: @plugin.id
  #   else
  #     @partial = @plugin.settings[:partial]
  #     @settings = Setting["plugin_#{@plugin.id}"]
  #   end
  # rescue Redmine::PluginNotFound
  #   render_404
  # end

  def default_breadcrumb
    l(@org_label)
    # if @org_type == OrganizationType.find_by(name: "Орган исполнительной власти").id
    #   l(:label_iogv)
    # elsif @org_type == OrganizationType.find_by(name: "Муниципальное образование").id
    #   l(:label_municipalities)
    # elsif @org_type == OrganizationType.find_by(name: "Контрагент").id
    #   l(:label_counterparties)
    # else
    #   l(:label_positions)
    # end
  end

  def show_local_breadcrumb
    true
  end

  private

  def parent_id_param
    params.fetch(:parent_id){0}
  end

  def find_organization
    @organization = Organization.find(params[:id])
    if @organization.parent_id != nil
      @organization_parent = Organization.find(@organization.parent_id)
    end
  end

  def respond_modal_with(*args, &blk)
    options = args.extract_options!
    options[:responder] = ModalResponder
    respond_with *args, options, &blk
  end

  def find_org_type
    # параметр из контроллера
    if params[:org_type]
      @org_type = OrganizationType.find(params[:org_type])
    end

    # параметр из меню
    case params[:type]
    when 'iogv'
      @org_type = OrganizationType.find_by(name: "Орган исполнительной власти")
    when 'municipalities'
      @org_type = OrganizationType.find_by(name: "Муниципальное образование")
    when 'counterparties'
      @org_type = OrganizationType.find_by(name: "Контрагент")
    when 'positions'
      @org_label = :label_positions
    end

    if @org_type == OrganizationType.find_by(name: "Орган исполнительной власти")
      @org_label = :label_iogv
    elsif @org_type == OrganizationType.find_by(name: "Муниципальное образование")
      @org_label = :label_municipalities
    elsif @org_type == OrganizationType.find_by(name: "Контрагент")
      @org_label = :label_counterparties
    else
      @org_label = :label_positions
    end

  end

end
