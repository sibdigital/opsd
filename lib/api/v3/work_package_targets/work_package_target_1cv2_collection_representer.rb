#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module WorkPackageTargets
      class WorkPackageTarget1CV2CollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::WorkPackageTargets::WorkPackageTarget1CV2Representer
      end
    end
  end
end
