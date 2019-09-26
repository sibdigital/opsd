#-- encoding: UTF-8
#by tan
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Periods
      class PeriodRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        self_link title_getter: ->(*) { represented.name }

        property :id, render_nil: true
        property :name
        property :position

        def _type
          'Period'
        end
      end
    end
  end
end
