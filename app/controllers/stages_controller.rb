class StagesController < ApplicationController
  menu_item :project_stages

  include StagesHelper

  def index
    @tab = params[:tab] || 'StageInitCustomField'
    respond_to do |format|
      format.atom do
        head(:gone)
      end
      format.html do
        render layout: 'no_menu'
      end
    end
  end

end
