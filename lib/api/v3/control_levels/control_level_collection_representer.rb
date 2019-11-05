#-- encoding: UTF-8
#by knm
#++

module API
  module V3
    module ControlLevels
      class ControlLevelCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::ControlLevels::ControlLevelRepresenter
      end
    end
  end
end


