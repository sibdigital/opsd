require 'api/v3/enumerations/enumeration_representer'
require 'api/v3/enumerations/enumeration_collection_representer'
module API
  module V3
    module Enumerations
      class EnumerationsAPI < ::API::OpenProjectAPI
        resources :enumerations do
          get do
            enumerations = Enumeration.all
            EnumerationCollectionRepresenter.new(enumerations,
                                                 api_v3_paths.enumerations,
                                                 current_user: current_user)
          end
          params do
            # requires :id, desc: 'Enumeration id'
            requires :type, desc: 'Enumeration type'
          end
          route_param :type do
            before do
              @enumerations_by_type = Enumeration.where(type: params[:type])
            end
            get do
              EnumerationCollectionRepresenter.new(@enumerations_by_type,
                                                   api_v3_paths.enumerations,
                                                   current_user: current_user)
            end
          end
        end
      end
    end
  end
end
