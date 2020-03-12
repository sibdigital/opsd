# bbm
module API
  module V3
    module WorkPackages
      class WorkPackagesDueAndFutureAPI < ::API::OpenProjectAPI
        resources :work_packages_due_and_future do
          get do
            authorize(:view_work_packages, global: true)
            projects = current_user.visible_projects.map(&:id)
            if params['project']
              project = params['project'] == '0' ? nil : params['project']
            end

            work_packages_due = WorkPackage.with_status_open
                                .where(plan_type: :execution, type: 2)
                                .where("due_date < now() - interval '1 day'")
                                .where(project_id: project ? project : projects)
            work_packages_due = work_packages_due.or(WorkPackage.with_status_open.where(plan_type: :execution, type: 1)
                                           .where("due_date between now() and now() + interval '2 week'")
                                           .where(project_id: project ? project : projects))
            
            if params['raion']
              raion = params['raion'] == '0' ? nil : params['raion']
              work_packages_due =  work_packages_due.where(raion_id: raion)
            end

            WorkPackageListRepresenter.new(
                work_packages_due,
                api_v3_paths.work_packages,
                current_user: current_user)
          end
        end
      end
    end
  end
end

