#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module Organizations
      class OrganizationCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::Organizations::OrganizationRepresenter
      end
    end
  end
end
