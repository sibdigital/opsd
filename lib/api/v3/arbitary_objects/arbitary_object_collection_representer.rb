#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module ArbitaryObjects
      class ArbitaryObjectCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::ArbitaryObjects::ArbitaryObjectRepresenter
      end
    end
  end
end
