#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module WorkPackageTargets
      class WorkPackageTargetCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::WorkPackageTargets::WorkPackageTargetRepresenter
      end
    end
  end
end
