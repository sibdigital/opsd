#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module HeadPerformances
      class HeadPerformanceCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::HeadPerformances::HeadPerformanceRepresenter
      end
    end
  end
end
