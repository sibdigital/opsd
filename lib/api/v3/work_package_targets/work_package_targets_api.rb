#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/work_package_targets/work_package_target_representer'
require 'api/v3/work_package_targets/work_package_target_collection_representer'

module API
  module V3
    module WorkPackageTargets
      class WorkPackageTargetsAPI < ::API::OpenProjectAPI
        resources :work_package_targets do
          before do
            authorize(:view_work_package_targets, global: true)
            @work_package_targets = if params[:project].present?
                                      WorkPackageTarget
                                        .where('project_id = ?', params[:project])
                                        .order('target_id asc, year asc, quarter asc, month asc')
                                    else
                                      WorkPackageTarget
                                        .where('work_package_id = ?', params[:work_package_id])
                                        .order('target_id asc, year asc, quarter asc, month asc')
                                    end
          end
          get do
            # @work_package_targets = if params[:project].present?
            #                           WorkPackageTarget
            #                           .where('project_id = ?', params[:project])
            #                           .order('target_id asc, year asc, quarter asc, month asc')
            #                         else
            #                           WorkPackageTarget
            #                             .where('work_package_id = ?', params[:work_package_id])
            #                             .order('target_id asc, year asc, quarter asc, month asc')
            #                         end

            #.where('work_package_id = ?', params[:work_package_id])
            WorkPackageTargetCollectionRepresenter.new(@work_package_targets,
                                                       api_v3_paths.work_package_targets,
                                                       current_user: current_user)
          end

          #TODO (zbd) добавить проверку на выполнение операции в соответствии с ролевой моделью
          post do
            authorize(:manage_work_package_targets, global: true)

            work_package_target = WorkPackageTarget.new
            work_package_target.target_id = params[:target_id]
            work_package_target.project_id = params[:project_id]
            work_package_target.work_package_id = params[:work_package_id]
            work_package_target.year = params[:year]
            work_package_target.quarter = params[:quarter]
            work_package_target.month = params[:month]
            work_package_target.plan_value = params[:plan_value]
            work_package_target.value = params[:value]
            work_package_target.save

            # @work_package_targets = WorkPackageTarget
            #                           .where('work_package_id = ?', params[:work_package_id])
            #                           .order('target_id asc, year asc, quarter asc, month asc')
            WorkPackageTargetCollectionRepresenter.new(@work_package_targets,
                                                        api_v3_paths.work_package_targets,
                                                        current_user: current_user)
          end

          route_param :id do
            get do
              authorize(:view_work_package_targets, global: true)

              @work_package_target = WorkPackageTarget.find(params[:id])

              WorkPackageTargetRepresenter.new(@work_package_target,
                                               current_user: current_user)
            end

            delete do
              #project = Project.find params[:project_id]
              #authorize(:manage_work_package_targets, context: project)
              authorize(:manage_work_package_targets, global: true)

              WorkPackageTarget.destroy params[:id]
            end
          end
        end

        resources :work_package_targets_1c do
          before do
            sql = "with slice as (select max(id) as id, project_id, target_id, work_package_id, year, quarter, max(month) as month
               from work_package_targets as wpt
               group by project_id, target_id, work_package_id, year, quarter
),
     slice_values as (
         select s.*, value, plan_value
         from slice as s
                  inner join work_package_targets as w
                             on (s.project_id, s.target_id, s.work_package_id, s.year, s.quarter, s.month) =
                                (w.project_id, w.target_id, w.work_package_id, w.year, w.quarter, w.month)
     )
select id, project_id, target_id, work_package_id, year, plan_value, value, 1 as quarter1, 0 as quarter2, 0 as quarter3, 0 as quarter4
FROM slice_values as wpt
where quarter = 1 and year = date_part('year', CURRENT_DATE)
union all
select id, project_id, target_id, work_package_id, year, plan_value, value, 0 as quarter1, 2 as quarter2, 0 as quarter3, 0 as quarter4
FROM slice_values as wpt
where quarter = 2 and year = date_part('year', CURRENT_DATE)
union all
select id, project_id, target_id, work_package_id, year, plan_value, value, 0 as quarter1, 0 as quarter2, 3 as quarter3, 0 as quarter4
FROM slice_values as wpt
where quarter = 3 and year = date_part('year', CURRENT_DATE)
union all
select id, project_id, target_id, work_package_id, year, plan_value, value, 0 as quarter1, 0 as quarter2, 0 as quarter3, 4 as quarter4
FROM slice_values as wpt
where quarter = 4 and year = date_part('year', CURRENT_DATE)
"
            @work_package_targets = []
            ActiveRecord::Base.connection.execute(sql).each { |wpt|
              @work_package_target = Hash.new
              @work_package_target['target'] = Target.find(wpt['target_id']).name
              @work_package_target['projectId'] = wpt['project_id']
              wp = WorkPackage.find(wpt['work_package_id'])
              @work_package_target['name'] = wp.subject
              @work_package_target['otvetstvenniy'] = wp.assigned_to
              @work_package_target['_type'] = 'Target'
              @work_package_target['quarter1'] = wpt['quarter1']
              @work_package_target['quarter2'] = wpt['quarter2']
              @work_package_target['quarter3'] = wpt['quarter3']
              @work_package_target['quarter4'] = wpt['quarter4']
              @work_package_targets << @work_package_target
            }
          end

          get do
            @work_package_targets
          end
        end
      end
    end
  end
end
