require 'roar/decorator'
require 'roar/json'
require 'roar/json/collection'
require 'roar/json/hal'

module API
  module V3
    module UserTasks
      class UserTaskCollectionRepresenter < ::API::Decorators::UnpaginatedCollection

        element_decorator ::API::V3::UserTasks::UserTaskRepresenter

      end
    end
  end
end
