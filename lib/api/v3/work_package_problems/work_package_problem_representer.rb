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
            href: api_v3_paths.work_package_problem(represented.id),
            title:if represented.risk_id.nil?
                    represented.description
                  else
                    ''#represented.name
                  end
          }
        end

        # property :name,
        #          render_nil: true,
        #          getter: ->(*) {
        #            if represented.risk_id.nil?
        #              represented.description
        #            else
        #              pr = ProjectRisk.find(represented.risk_id).first
        #              if pr.present?
        #                pr.name
        #              else
        #                nil
        #              end
        #            end
        #          }

        property :id, render_nil: true
        property :project_id
        property :work_package_id
        property :risk_id
        property :user_creator_id
        property :user_source_id
        property :organization_source_id
        property :status
        property :type
        property :solution_date
        property :description

        def _type
          'WorkPackageProblem'
        end
      end
    end
  end
end
