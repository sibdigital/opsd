#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module WorkPackageProblems
      class WorkPackageProblemRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        link :self do
          {
            href: api_v3_paths.work_package_target(represented.id),
            title: Risk.where(id: represented.risk_id).first.name
          }
        end

        property :id, render_nil: true
        property :project_id
        property :work_package_id
        property :risk_id
        property :user_creator_id

        def _type
          'WorkPackageProblem'
        end
      end
    end
  end
end
