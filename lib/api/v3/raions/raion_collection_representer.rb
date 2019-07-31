#-- encoding: UTF-8
#by tan
#++

module API
  module V3
    module Raions
      class RaionCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::Raions::RaionRepresenter
      end
    end
  end
end
