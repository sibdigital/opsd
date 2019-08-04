#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module Boards
      class BoardCollectionRepresenter < ::API::Decorators::OffsetPaginatedCollection
        element_decorator ::API::V3::Boards::BoardRepresenter
      end
    end
  end
end
