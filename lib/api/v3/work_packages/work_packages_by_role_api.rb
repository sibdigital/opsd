# bbm
module API
  module V3
    module WorkPackages
      class WorkPackagesByRoleAPI < ::API::OpenProjectAPI
        helpers ::API::V3::Utilities::RoleHelper

        resources :work_packages_by_role do
          get do
            authorize(:view_work_packages, global: true)
            projects = []
            Project.visible_by(current_user).each do |project|
              exist = which_role(project, current_user, global_role)
              if exist
                projects << project.id.to_s
              end
            end
            filters = params[:filters]
            filters = if filters
                        filters.chop + ',{"project":{"operator":"=","values":[' + projects.join(',') + ']}}]'
                      else
                        '[{"project":{"operator":"=","values":[' + projects.join(',') + ']}}]'
                      end

            project = JSON.parse(params[:filters]).select{|e| e["project"]}
            service = if projects.empty?
                        WorkPackageCollectionFromQueryParamsService
                          .new(current_user)
                          .call(params.merge(pageSize: 0)) # nothing
                      elsif project.empty?
                        WorkPackageCollectionFromQueryParamsService
                          .new(current_user)
                          .call(params.merge(pageSize: 500, filters: filters)) # as unlimited: 500 - max
                      else
                        WorkPackageCollectionFromQueryParamsService
                          .new(current_user)
                          .call(params.merge(pageSize: 500)) # as unlimited: 500 - max
                      end
            if service.success?
              service.result
            else
              api_errors = service.errors.full_messages.map do |message|
                ::API::Errors::InvalidQuery.new(message)
              end

              raise ::API::Errors::MultipleErrors.create_if_many api_errors
            end
          end
        end
      end
    end
  end
end
