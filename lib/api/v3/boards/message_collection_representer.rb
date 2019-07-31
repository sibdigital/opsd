#-- encoding: UTF-8
#by zbd
#++

module API
  module V3
    module Boards
      class MessageCollectionRepresenter < ::API::Decorators::OffsetPaginatedCollection
        element_decorator ::API::V3::Boards::MessageRepresenter

        def initialize(models, self_link, query: {}, page: nil, per_page: nil, current_user:)
          @current_user = current_user

          super(models, self_link, query: query, page: page, per_page: per_page, current_user: current_user)
        end

      end
    end
  end
end
