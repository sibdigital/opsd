#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module WorkPackageTargets
      class PlanFactValueCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::WorkPackageTargets::PlanFactValueRepresenter
      end
    end
  end
end
