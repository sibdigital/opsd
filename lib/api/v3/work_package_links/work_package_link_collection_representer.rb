module API
  module V3
    module WorkPackageLinks
      class WorkPackageLinkCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::WorkPackageLinks::WorkPackageLinkRepresenter
        self.to_eager_load = ::API::V3::WorkPackageLinks::WorkPackageLinkRepresenter.to_eager_load
      end
    end
  end
end
