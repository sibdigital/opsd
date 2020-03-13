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
            if params['offset_upcoming']
              offset_upcoming = params['offset_upcoming'] == '0' ? 1 :Integer( params['offset_upcoming'])
            end
            if params['offset_due']
              offset_due = params['offset_due'] == '0' ? 1 : Integer(params['offset_due'])
            end
            if params['pageSize']
              page_size = params['pageSize']  == '0' ? 5 : Integer(params['pageSize'])
            end
            work_packages_due = WorkPackage.with_status_open
                                .where(plan_type: :execution, type: 2)
                                .where("due_date < now() - interval '1 day'")
                                .where(project_id: project ? project : projects)
                .first(offset_due*page_size)
                                    .last(page_size)
            work_packages_future = WorkPackage.with_status_open.where(plan_type: :execution, type: 1)
                                       .where("due_date between now() and now() + interval '2 week'")
                                       .where(project_id: project ? project : projects)
                                       .first(offset_upcoming*page_size)
                                       .last(page_size)


            if params['raion']
              raion = params['raion'] == '0' ? nil : params['raion']
              work_packages_due =  work_packages_due.where(raion_id: raion)
              work_packages_future =  work_packages_future.where(raion_id: raion)
            end
          end
        end
      end
    end
  end
end

