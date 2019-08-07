#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/work_package_targets/work_package_target_representer'
require 'api/v3/work_package_targets/work_package_target_collection_representer'
require 'api/v3/work_package_targets/work_package_target_1c_representer'
require 'api/v3/work_package_targets/work_package_target_1c_collection_representer'

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

            patch do
              authorize :manage_work_package_targets, global: true #context: project

              WorkPackageTarget.update params[:id], params
            end

          end
        end

        resources :work_package_targets_1c do
          before do
            @work_package_targets = WorkPackageQuarterlyTarget.where("year = date_part('year', CURRENT_DATE)")
          end

          get do
            WorkPackageTarget1CCollectionRepresenter.new(@work_package_targets,
                                                       api_v3_paths.work_package_targets,
                                                       current_user: current_user)
          end
        end
      end
    end
  end
end
