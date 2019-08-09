#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module WorkPackageTargets
      class PlanFactValueRepresenter < ::API::Decorators::Single

        link :self do
          {
            href: api_v3_paths.work_package_target(represented.id),
            #href: api_v3_paths.plan_fact_quarterly_target_values(represented.id),
            title: Target.where(id: represented.target_id).first.name
          }
        end

        property :project_id, render_nil: true
        property :target_id, render_nil: true
        property :year, render_nil: true
        property :target_year_value, render_nil: true

        property :target_quarter1_value, render_nil: true
        property :target_quarter2_value, render_nil: true
        property :target_quarter3_value, render_nil: true
        property :target_quarter4_value, render_nil: true

        property :plan_quarter1_value, render_nil: true
        property :plan_quarter2_value, render_nil: true
        property :plan_quarter3_value, render_nil: true
        property :plan_quarter4_value, render_nil: true

        property :fact_quarter1_value, render_nil: true
        property :fact_quarter2_value, render_nil: true
        property :fact_quarter3_value, render_nil: true
        property :fact_quarter4_value, render_nil: true

        def _type
          'PlanFactValue'
        end
      end
    end
  end
end
