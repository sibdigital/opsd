#-- encoding: UTF-8
#by knm
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module ControlLevels
      class ControlLevelRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        self_link title_getter: ->(*) { represented.name }

        property :id, render_nil: true
        property :name
        property :code

        def _type
          'ControlLevel'
        end
      end
    end
  end
end

