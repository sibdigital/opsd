class PlanUploaderSettingsController < ApplicationController

  layout 'admin'

  before_action :find_setting, only: [:edit, :update, :destroy]
  before_action :get_columns, only: [:new, :edit, :update]

  def index
    @plan_uploader_settings = PlanUploaderSetting.order('table_name asc, column_num asc').all
  end

  def edit
    @plan_uploader_setting = PlanUploaderSetting.find(params[:id])
  end

  def new
    @plan_uploader_setting = PlanUploaderSetting.new
    @plan_uploader_setting.table_name = 'work_packages'
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

  protected

  def find_setting
    @plan_uploader_setting = PlanUploaderSetting.find(params[:id])
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

  def default_breadcrumb
    if action_name == 'index'
      'Настройка полей'
    else
      ActionController::Base.helpers.link_to('Настройка полей', plan_uploader_setting_path)
    end
  end

  def show_local_breadcrumb
    true
  end
end
