#-- encoding: UTF-8
#by tan
#++

require 'api/v3/control_levels/control_level_representer'
require 'api/v3/control_levels/control_level_collection_representer'

module API
  module V3
    module ControlLevels
      class ControlLevelsAPI < ::API::OpenProjectAPI
        resources :control_levels do
          before do
            authorize(:view_work_packages, global: true)
            @control_levels = ControlLevel.all
          end

          get do
            ControlLevelCollectionRepresenter.new(@control_levels,
                                            api_v3_paths.control_levels,
                                            current_user: current_user)
          end

          route_param :id do
            before do
              @control_level = ControlLevel.find(params[:id])
            end
            get do
              ControlLevelRepresenter.new(@control_level, current_user: current_user)
            end
          end
        end
      end
    end
  end
end


