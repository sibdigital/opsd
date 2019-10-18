#-- encoding: UTF-8
#by knm
#++

module API
  module V3
    module Periods
      class PeriodCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::Periods::PeriodRepresenter
      end
    end
  end
end

