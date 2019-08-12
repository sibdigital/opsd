#-- encoding: UTF-8
#+-tan 2019.04.25

class OrgSettingsController < ApplicationController
  layout 'admin'
  menu_item :org_settings
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper
  include TargetsHelper
  before_action :require_project_admin

  def index
    sort_columns = {'id' => "#{Organization.table_name}.id",
                    'name'=>"#{Organization.table_name}.name"
    }
    sort_init [['parent_id', 'asc'],['id', 'asc']]
    sort_update sort_columns
    @organizations = Organization.order(sort_clause).page(page_param).per_page(per_page_param)
    @iogv = Enumeration.find_by(name: "Орган исполнительной власти")
    @municipalities = Enumeration.find_by(name: "Муниципальное образование")
    @counterparties = Enumeration.find_by(name: "Контрагент")
    @parent_id = parent_id_param

    if @parent_id.to_i != 0
      @organization_parent = Organization.find(@parent_id)
    end

    edit
    render action: 'edit'
  end

  def iogv
    @iogv = Enumeration.find_by(name: "Орган исполнительной власти")
    @org_type = Enumeration.find_by(name: "Орган исполнительной власти").id
    @parent_id = parent_id_param

    if @parent_id.to_i != 0
      @organization_parent = Organization.find(@parent_id)
    end
  end

  def municipalities
    @municipalities = Enumeration.find_by(name: "Муниципальное образование")
    @org_type = Enumeration.find_by(name: "Муниципальное образование").id
    @org_type.to_param
    @parent_id = parent_id_param

    if @parent_id.to_i != 0
      @organization_parent = Organization.find(@parent_id)
    end
  end

  def counterparties
    @counterparties = Enumeration.find_by(name: "Контрагент")
    @org_type = Enumeration.find_by(name: "Контрагент").id
    @parent_id = parent_id_param

    if @parent_id.to_i != 0
      @organization_parent = Organization.find(@parent_id)
    end
  end

  def positions
    # @org_type = Enumeration.find_by(name: "Орган исполнительной власти").id
    # @parent_id = parent_id_param
    #
    # if @parent_id.to_i != 0
    #   @organization_parent = Organization.find(@parent_id)
    # end
  end

  def edit
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
  end
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
    l(:label_org_settings)
  end

  def show_local_breadcrumb
    true
  end

  private

 def parent_id_param
    params.fetch(:parent_id){0}
  end

end
