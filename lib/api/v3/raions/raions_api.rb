#-- encoding: UTF-8
#by tan
#++

require 'api/v3/raions/raion_representer'
require 'api/v3/raions/raion_collection_representer'

module API
  module V3
    module Raions
      class RaionsAPI < ::API::OpenProjectAPI
        resources :raions do
          before do
            authorize(:view_work_packages, global: true)
            @raions = Raion.all
          end

          get do
            RaionCollectionRepresenter.new(@raions,
                                              api_v3_paths.raions,
                                              current_user: current_user)
          end

           route_param :id do
             before do
               @raion = Raion.find(params[:id])
             end
            get do
              RaionRepresenter.new(@raion, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
