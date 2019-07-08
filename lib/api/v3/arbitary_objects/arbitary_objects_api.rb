#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/arbitary_objects/arbitary_object_representer'
require 'api/v3/arbitary_objects/arbitary_object_collection_representer'

module API
  module V3
    module ArbitaryObjects
      class ArbitaryObjectsAPI < ::API::OpenProjectAPI
        resources :arbitary_objects do
          before do
            authorize(:view_work_packages, global: true)
            @arbitary_objects = ArbitaryObject.all
          end

          get do
            ArbitaryObjectCollectionRepresenter.new(@arbitary_objects,
                                              api_v3_paths.arbitary_objects,
                                              current_user: current_user)
          end

           route_param :id do
             before do
               @arbitary_object = ArbitaryObjects.find(params[:id])
             end
            get do
              ArbitaryObjectRepresenter.new(@arbitary_object, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
