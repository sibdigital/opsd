class TargetsController < ApplicationController
  #layout 'base'
  default_search_scope :targets

  before_action :find_optional_project, :verify_targets_module_activated
  before_action :find_target, only: [:edit, :update, :destroy]
  before_action :authorize

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper
  include TargetsHelper

  def index
    sort_columns = {'id' => "#{Target.table_name}.id",
                    'name' => "#{Target.table_name}.name",
                    'status' => "#{Target.table_name}.status_id",
                    'type' => "#{Target.table_name}.type_id"
    }

    sort_init [['parent_id', 'asc'],['id', 'asc']]
    sort_update sort_columns

    default = false
    @title = nil
    name = ""

    case params[:target_type]
    when "target"
      @title = "Цели"
      name = I18n.t('targets.target')
    when "indicator"
      @title = "Целевые показатели"
      name = I18n.t('targets.indicator')
    when "result"
      @title = "Результаты"
      name = I18n.t('targets.result')
    else
      default = true
    end

    type_id = TargetType.where(:name => name).pluck(:id)

    @parent_id = parent_id_param

    if default
      @targets = @project.targets
                   .order(sort_clause)
                   .page(page_param)
                   .per_page(per_page_param)
    else
      @targets = @project.targets
                   .where(:type_id => type_id[0])
                   .order(sort_clause)
                   .page(page_param)
                   .per_page(per_page_param)
    end

  end

  def edit
    @targets_arr = [['', 0]]
    @targets_arr += Target.where('project_id = ? and id <> ?', @project.id, @target.id).map {|u| [u.name, u.id]}
  end

  def new
    @target = Target.new

    @target.project_id = find_project_by_project_id.id
    if params[:parent_id] != nil
      @parent_id = params[:parent_id]
    else
      @parent_id = 0
    end

    @target.parent_id = @parent_id
    if @target.parent_id != 0
      @target_parent = Target.find(@parent_id)
    end

    @targets_arr = [['', 0]]
    @targets_arr += Target.where('project_id = ?', @project.id).map {|u| [u.name, u.id]}
  end

  def choose_typed
    if request.post? && params[:choose_typed]
      permitted_params.choose_typed.to_h.each do |name, values|
        if values.is_a?(Array)
          # remove blank values in array settings
          values.delete_if(&:blank?)
        end
        Target.transaction do
          values.each do |value|
            target = copy_typed_to_project value.to_i
            target.save
            # TODO: target_charact - скопировать из потомков typed-a и сохранить
          end
          flash[:notice] = l(:notice_successful_create)
        rescue Exception => e
          flash[:error] = e.message
          raise ActiveRecord::Rollback
        end
      end
      redirect_to project_targets_path #action: 'index'
    end
  end

  def create
    @target = @project.targets.create(permitted_params.target)

    if @target.save
      flash[:notice] = l(:notice_add_target_values)
      redirect_to edit_project_target_path(id: @target.id) #action: 'edit'

    else
      render action: 'new'
    end
  end

  def update
    if @target.update_attributes(permitted_params.target)
      flash[:notice] = l(:notice_successful_update)
      #redirect_to project_targets_path()
      redirect_to edit_project_target_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @target.destroy
    redirect_to project_targets_path # action: 'index'
    nil
  end

  protected

  def find_target
    @target = @project.targets.find(params[:id])
    if @target.parent_id != 0
      @target_parent = Target.find(@target.parent_id)
    end
  end

  def default_breadcrumb
    if action_name == 'index'
      t(:label_targets)
    else
      #ActionController::Base.helpers.link_to(t(:label_targets), project_targets_path(project_id: @project.identifier))
      ActionController::Base.helpers.link_to(t(:label_targets), project_targets_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  private

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def verify_targets_module_activated
    render_403 if @project && !@project.module_enabled?('targets')
  end

  def copy_typed_to_project(id)
    typed_target = TypedTarget.find(id)
    target = @project.targets.build
    target.name = typed_target.name
    target.status_id = typed_target.status_id
    target.type_id = typed_target.type_id
    target.measure_unit_id = typed_target.measure_unit_id
    target.basic_value = typed_target.basic_value
    target.plan_value = typed_target.plan_value
    target.comment = typed_target.comment
    target.is_approve = typed_target.is_approve
    target.type = nil
    target.parent_id = 0

    # typed_target.risk_characts.each do |typed_target_charact|
    #   target_charact = target.risk_characts.build
    #   target_charact.name = typed_target_charact.name
    #   target_charact.description = typed_target_charact.description
    #   target_charact.type = typed_target_charact.type
    #   target_charact.position = typed_target_charact.position
    # end
    target
  end

  def remove_quotations(str)
    if str.start_with?('"')
      str = str.slice(1..-1)
    end
    if str.end_with?('"')
      str = str.slice(0..-2)
    end
  end

  def parent_id_param
    params.fetch(:parent_id){0}
  end

end
