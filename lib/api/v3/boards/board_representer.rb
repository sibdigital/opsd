#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Boards
      class BoardRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        self_link title_getter: ->(*) { represented.name }

        property :id, render_nil: true
        property :name, render_nil: true
        property :project, render_nil: true
        property :description, render_nil: true
        property :topics, render_nil: true

        def _type
          'Board'
        end
      end
    end
  end
end
