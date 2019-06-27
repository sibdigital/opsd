#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module Contracts
      class ContractCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::Contracts::ContractRepresenter
      end
    end
  end
end
