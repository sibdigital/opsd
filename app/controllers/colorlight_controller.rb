class ColorlightController < ApplicationController
  layout 'admin'
  before_action :authorize_global, only: [:index]

  def index; end

  def create
    # code here
  end
end
