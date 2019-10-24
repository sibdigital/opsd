require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module UserTasks
      class UserTaskRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        self_link

        property :id, render_nil: true
        property :text, render_nil: true
        property :created_at, render_nil: true

        def _type
          'UserTask'
        end
      end
    end
  end
end
