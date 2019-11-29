#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module HeadPerformances
      class HeadPerformanceRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        link :self do
          {
            href: api_v3_paths.head_performance_indicator(represented.id),
            title: represented.name
          }
        end

        property :id, render_nil: true
        property :value,
                 exec_context: :decorator,
                 getter: ->(*) { indicator_value(represented) },
                 render_nil: true
        property :name
        property :sort_code

        def _type
          'HeadPerformance'
        end

        def indicator_value(represented)
          v = represented.head_performance_indicator_values.order(:year, :quarter, :month).last
          v ? v.value : nil
        end
      end
    end
  end
end
