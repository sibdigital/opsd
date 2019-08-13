#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module WorkPackageTargets
      class WorkPackageTarget1CV2Representer < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        link :self do
          {
            href: api_v3_paths.work_package_target_1cv2(represented.id),
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
                 getter: ->(*) { represented.work_package.assigned_to },
                 render_nil: true

        property :done_ratio,
                 exec_context: :decorator,
                 getter: ->(*) { represented.work_package.done_ratio },
                 render_nil: true

        property :project_id, render_nil: true

        property :national_id,
                 exec_context: :decorator,
                 getter: ->(*) { represented.project.national_project_id || 0 },
                 render_nil: true

        property :quarter1_value, render_nil: true
        property :quarter1_plan_value, render_nil: true
        property :quarter2_value, render_nil: true
        property :quarter2_plan_value, render_nil: true
        property :quarter3_value, render_nil: true
        property :quarter3_plan_value, render_nil: true
        property :quarter4_value, render_nil: true
        property :quarter4_plan_value, render_nil: true

        def _type
          'WorkPackageTarget1CV2'
        end
      end
    end
  end
end
