# bbm
module API
  module V3
    module WorkPackages
      class WorkPackagesFutureAPI < ::API::OpenProjectAPI
        helpers ::API::V3::Utilities::RoleHelper

        resources :work_packages_future do
          get do
            authorize(:view_work_packages, global: true)
            projects = current_user.visible_projects.map(&:id)
            if params['project']
              project = params['project'] == '0' ? nil : params['project']
            end

            work_packages = WorkPackage.with_status_open
                      .where(plan_type: :execution, type: 1)
                      .where("due_date between now() and now() + interval '2 week'")
                      .where(project_id: project ? project : projects)

            if params['raion']
              raion = params['raion'] == '0' ? nil : params['raion']
              work_packages =  work_packages.where(raion_id: raion)
            end

            ::API::V3::WorkPackages::WorkPackageCollectionRepresenter.new(
                work_packages,
                api_v3_paths.work_packages,
                groups: nil,
                page: params[:offset] ? params[:offset].to_i : nil,
                per_page: params[:pageSize] ? params[:pageSize].to_i : nil,
                total_sums: nil,
                embed_schemas: true,
                current_user: current_user)

=begin
            service = if projects.empty?
                        WorkPackageCollectionFromQueryParamsService
                          .new(current_user)
                          .call(params.merge(pageSize: 0)) # nothing
                      elsif project.empty?
                        WorkPackageCollectionFromQueryParamsService
                          .new(current_user)
                          .call(params.merge(pageSize: 500, filters: params[:filters])) # as unlimited: 500 - max
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
=end
          end
        end
      end
    end
  end
end
