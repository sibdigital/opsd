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

          get do
            authorize(:manage_work_package_targets_plan_value, global: true)
            @work_package_targets = WorkPackageTarget
                                      .joins(:target)
                                      .where('work_package_id = ?', params[:work_package_id])
                                      .order('target_id asc, year asc, quarter asc, month asc')
            # @work_package_targets = WorkPackageTarget.find_by_sql(
            #         'select wpt.id, wpt.project_id, wpt.work_package_id, wpt.target_id, wpt.year,wpt.quarter,wpt.month,
            #           wpt.value, wpt.type, wpt.plan_value, wpt.created_at, wpt.updated_at, t.name
            #           from work_package_targets wpt inner join targets t on t.id=wpt.target_id
            #           where wpt.work_package_id = '+params[:work_package_id] + '
            #           order by target_id asc, year asc, quarter asc, month asc')
            # .select('work_package_targets.project_id, work_package_targets.work_package_id, work_package_targets.target_id,
            #     work_package_targets.year,work_package_targets.quarter,work_package_targets.month,
            #     work_package_targets.value,work_package_targets.type,work_package_targets.plan_value, targets.name')
            WorkPackageTargetCollectionRepresenter.new(@work_package_targets,
                                           api_v3_paths.work_package_targets,
                                           current_user: current_user)
          end

          #TODO (zbd) добавить проверку на выполнение операции в соответствии с ролевой моделью
          post do
            authorize(:manage_work_package_targets_plan_value, global: true)
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

            @work_package_targets = WorkPackageTarget
                                      .where('work_package_id = ?', params[:work_package_id])
                                      .order('target_id asc, year asc, quarter asc, month asc')
            WorkPackageTargetCollectionRepresenter.new(@work_package_targets,
                                                       api_v3_paths.work_package_targets,
                                                       current_user: current_user)
          end

          route_param :id do
            before do
              @work_package_target = WorkPackageTarget.find(params[:id])
            end

            get do
              WorkPackageTargetRepresenter.new(@work_package_target, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
