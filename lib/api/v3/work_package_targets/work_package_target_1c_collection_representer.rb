#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module WorkPackageTargets
      class WorkPackageTarget1CCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::WorkPackageTargets::WorkPackageTarget1CRepresenter
      end
    end
  end
end
