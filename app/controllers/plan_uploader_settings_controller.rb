class PlanUploaderSettingsController < ApplicationController

  layout 'admin'

  before_action :find_setting, only: [:edit, :update, :destroy]
  # before_action :get_columns, only: [:new, :edit, :update]
  before_action :get_tables, only: [:new, :edit, :update]

  attr_accessor :selected_table


  def index
    @plan_uploader_settings_types = PlanUploaderSetting.select(:setting_type).group('setting_type').order('setting_type asc').all
    @plan_uploader_settings = PlanUploaderSetting.order('table_name asc, column_num asc').all
  end

  def edit
    @plan_uploader_setting = PlanUploaderSetting.find(params[:id])
  end

  def new
    @plan_uploader_setting = PlanUploaderSetting.new
    # @plan_uploader_setting.table_name = 'work_packages'
    get_tables
    get_columns
  end

  def create
    @plan_uploader_setting = PlanUploaderSetting.new(permitted_params.plan_uploader_setting)

    if @plan_uploader_setting.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @plan_uploader_setting.update_attributes(permitted_params.plan_uploader_setting)
      flash[:notice] = l(:notice_successful_update)
      redirect_to plan_uploader_settings_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @plan_uploader_setting.destroy
    redirect_to action: 'index'
    return
  end

  def update_column
    selected_column = params["selectedColumn"]
    not_permitted_fields = ["id", "created_at", "updated_at"]
    catalog = nil

    @columns = []

    case selected_column
      when "contracts"
        catalog = Contract

      when "work_packages"
        catalog = WorkPackage
    end

    catalog.column_names.each do |col|
      if !col.in?(not_permitted_fields)
        @columns << [catalog.human_attribute_name(col), col]
      end
    end

    @columns
  end

  protected

  def get_tables
    @table = [
                ["Мероприятия", "work_packages"],
                ["Государственные контракты", "contracts"]
              ]
  end

  def get_columns
    not_permit_fields = ["id", "created_at", "updated_at"]
    @columns = []
    WorkPackage.column_names.each_with_index do |col, index|
      if !col.in?(not_permit_fields)
        @columns << [WorkPackage.human_attribute_name(col), col]
      end
    end
  end

  def find_setting
    @plan_uploader_setting = PlanUploaderSetting.find(params[:id])
  end

  def default_breadcrumb
    if action_name == 'index'
      'Настройка полей'
    else
      'Настройка полей'
      #ActionController::Base.helpers.link_to('Настройка полей', plan_uploader_setting_path)
    end
  end

  def show_local_breadcrumb
    true
  end
end
