# bbm
module API
  module V3
    module WorkPackages
      class WorkPackagesDueAPI < ::API::OpenProjectAPI

        resources :work_packages_due do
          get do
            authorize(:view_work_packages, global: true)
            projects = current_user.visible_projects.map(&:id)
            if params['project']
              project = params['project'] == '0' ? nil : params['project']
            end

            work_packages = WorkPackage.with_status_open
                      .where(plan_type: :execution, type: 2)
                      .where("due_date < now() - interval '1 day'")
                      .where(project_id: project ? project : projects)

            if params['raion']
              raion = params['raion'] == '0' ? nil : params['raion']
              work_packages =  work_packages.where(raion_id: raion)
            end

            CompactWorkPackageCollectionRepresenter.new(
                work_packages,
                api_v3_paths.work_packages,
                page: params[:offset] ? params[:offset].to_i : nil,
                per_page: params[:pageSize] ? params[:pageSize].to_i : nil,
                current_user: current_user)
          end
        end
      end
    end
  end
end
