#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module WorkPackageTargets
      class WorkPackageTargetRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        link :self do
          {
            href: api_v3_paths.work_package_target(represented.id),
            title: Target.where(id: represented.target_id).first.name
          }
        end

        property :name,
                 exec_context: :decorator,
                 getter: ->(*) { represented.work_package.name },
                 render_nil: true

        property :target,
                 exec_context: :decorator,
                 getter: ->(*) { represented.target.name },
                 render_nil: true

        property :otvetstvenniy,
                 exec_context: :decorator,
                 getter: ->(*) { represented.project.curator },
                 render_nil: true

        # property :plan_fact_quarterly_target_value,
        #          exec_context: :decorator,
        #          getter: ->(*) {
        #            #PlanFactQuarterlyTargetValue.where(target_id: represented.target_id, project_id: represented.project_id)
        #            PlanFactQuarterlyTargetValue.where(project_id: represented.project_id)
        #          },
        #          render_nil: true

        property :can_edit_plan_values,
                 exec_context: :decorator,
                 uncacheable: true,
                 getter: ->(*) {
                   current_user_allowed_to(:manage_work_package_target_plan_values, context: represented.project)
                 },
                 render_nil: true

        property :can_edit_fact_values,
                 exec_context: :decorator,
                 uncacheable: true,
                 getter: ->(*) {
                   current_user_allowed_to(:edit_work_package_target_fact_values, context: represented.project)
                 },
                 render_nil: true

        property :id, render_nil: true
        property :project_id
        property :work_package_id
        property :target_id
        property :year, render_nil: true
        property :quarter, render_nil: true
        property :month, render_nil: true
        property :type, render_nil: true
        property :value, render_nil: true
        property :plan_value, render_nil: true

        def _type
          'WorkPackageTarget'
        end
      end
    end
  end
end
