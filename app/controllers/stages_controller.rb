class StagesController < ApplicationController
  menu_item :project_stages

  include StagesHelper

  def index
    @tab = params[:tab] || 'StageInitCustomField'
  end

end
