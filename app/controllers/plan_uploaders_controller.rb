#-- encoding: UTF-8
#+-tan 2019.04.25
class PlanUploadersController < ApplicationController

  layout 'admin'

  def index
    @plan_uploaders = PlanUploader.all
  end

  def new
    @plan_uploader = PlanUploader.new
  end

  def create
    @plan_uploader = PlanUploader.new(permitted_params.plan_uploader)

    if @plan_uploader.save
      # redirect_to resumes_path, notice: "The resume #{@resume.name} has been uploaded."
    else
      render "new"
    end

  end

  def destroy
    # @plan_uploaders = Resume.find(params[:id])
    # @plan_uploaders.destroy
    # redirect_to resumes_path, notice:  "The resume #{@resume.name} has been deleted."
  end

  # private
  # def plan_uploader_params
  #   params.require(:plan_uploader).permit(:name, :attachment, :status, :upload_at)
  # end
end
