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

        #self_link

        link :self do
          {
            href: api_v3_paths.work_package_target(represented.id),
            title: Target.where(id: represented.target_id).first.name
          }
        end

        link :project do
          {
            href: api_v3_paths.project(represented.project_id),
            title: represented.project.name
          }
        end

        link :work_package do
          {
            href: api_v3_paths.work_package(represented.work_package_id),
            title: represented.work_package.subject
          }
        end

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
