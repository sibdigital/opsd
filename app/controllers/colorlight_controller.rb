class ColorlightController < ApplicationController
  include Downloadable
  layout 'admin'
  before_action :authorize_global, only: [:index]

  def index; end

  def create
    if params[:number] == "1"
      @ready = Colorlight.create_xlsx(params['type'].to_i)
      send_to_user filepath: @ready
    elsif params[:number] == "2"
      url = Setting[:jopsd_url] + '/jopsd/generate_light_report/xlsx/params?typeId=' + params[:type]
      redirect_to url
    end
  end
end
