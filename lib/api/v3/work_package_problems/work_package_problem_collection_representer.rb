#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module WorkPackageProblems
      class WorkPackageProblemCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::WorkPackageProblems::WorkPackageProblemRepresenter
      end
    end
  end
end
