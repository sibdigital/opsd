class PlanUploaderSettingsController < ApplicationController

  layout 'admin'

  before_action :find_setting, only: [:edit, :update, :destroy]
  before_action :get_setting_types, except: [:destroy]

  attr_accessor :selected_table


  def index
    @plan_uploader_settings = PlanUploaderSetting.order('table_name asc, column_num asc').all
  end

  def edit
    @setting_type = params['setting_type']
    @plan_uploader_setting = PlanUploaderSetting.find(params[:id])
    get_columns
  end

  def new
    @setting_type = params['setting_type']
    @plan_uploader_setting = PlanUploaderSetting.new
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
    when "organizations"
      catalog = Organization
    when "users"
      catalog = User
    when "risks"
      catalog = Risk
    when "positions"
      catalog = Position
    when "arbitary_objects"
      catalog = ArbitaryObject
    when "groups"
      catalog = Group
    end

    if selected_column == "groups"
      @columns << {
        'human_name': "Наименование",
        'name': "lastname"
      }
    else
      catalog.column_names.each do |col|
        if !col.in?(not_permitted_fields)
          @columns << {
            'human_name': catalog.human_attribute_name(col),
            'name': col
          }
        end
      end
    end


    render json: @columns
  end

  protected

  def get_setting_types
    # массив типов для общего списка
    @plan_uploader_settings_types = PlanUploaderSetting.select(:setting_type).group('setting_type').order('setting_type asc').all
    # массив типов для select'ов
    @settings_types = []
    @plan_uploader_settings_types.each do |setting|
      @settings_types << [setting.setting_type, setting.setting_type]
    end

    if !@settings_types.include?(['UploadPlanType1', 'UploadPlanType1'])
      @settings_types << ['UploadPlanType1', 'UploadPlanType1']
    end
    if !@settings_types.include?(['UploadPlanType2', 'UploadPlanType2'])
      @settings_types << ['UploadPlanType2', 'UploadPlanType2']
    end
    @settings_types << ['выберите для ввода новой настройки', 999]
    # текущее значение
    @setting_type = params[:setting_type]
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
