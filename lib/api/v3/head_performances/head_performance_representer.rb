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
            href: api_v3_paths.work_package_target(represented.id),
            title: represented.name
          }
        end

        property :id, render_nil: true
        property :value,
                 exec_context: :decorator,
                 getter: ->(*) { represented.head_performance_indicator_values.last ? represented.head_performance_indicator_values.last.value : nil },
                 render_nil: true
        property :name
        property :sort_code

        def _type
          'HeadPerformances'
        end
      end
    end
  end
end
