class BibliotekaOtchetovController < ApplicationController
  menu_item :biblioteka_otchetov

  before_action :find_optional_project, :verify_reporting_module_activated

  def index
    @documents = Document
                   .where(category: DocumentCategory.find_by(name: 'Отчет о ходе реализации проекта'),
                          project: @project)
                  # .order(id: :desc)
  end

  protected

  def show_local_breadcrumb
    true
  end

  private

  def file_download(path_method)
    @custom_style = CustomStyle.current
    if @custom_style && @custom_style.send(path_method)
      expires_in 1.years, public: true, must_revalidate: false
      send_file(@custom_style.send(path_method))
    else
      head :not_found
    end
  end

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def verify_reporting_module_activated
    Rails.logger.info @project && !@project.module_enabled?('reporting_module')
    render_403 if @project && !@project.module_enabled?('reporting_module')
  end
end
