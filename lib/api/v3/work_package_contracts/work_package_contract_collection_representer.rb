module API
  module V3
    module WorkPackageContracts
      class WorkPackageContractCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::WorkPackageContracts::WorkPackageContractRepresenter
        self.to_eager_load = ::API::V3::WorkPackageContracts::WorkPackageContractRepresenter.to_eager_load
      end
    end
  end
end
