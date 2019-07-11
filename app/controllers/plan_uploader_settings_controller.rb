class PlanUploaderSettingsController < ApplicationController

  layout 'admin'

  before_action :find_setting, only: [:edit, :update, :destroy]

  def index
    @plan_uploader_settings = PlanUploaderSetting.order('column_num asc').all
  end

  def edit
    @plan_uploader_setting = PlanUploaderSetting.find(params[:id])
  end

  def new
    @plan_uploader_setting = PlanUploaderSetting.new
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
end
