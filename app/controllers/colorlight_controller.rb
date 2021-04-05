class ColorlightController < ApplicationController
  include Downloadable
  layout 'admin'
  before_action :authorize_global, only: [:index]

  def index; end

  def create
    @ready = Colorlight.create_xlsx(params['type'].to_i)
    send_to_user filepath: @ready
  end
end
