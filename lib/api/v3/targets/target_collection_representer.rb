#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module Targets
      class TargetCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::Targets::TargetRepresenter
      end
    end
  end
end
