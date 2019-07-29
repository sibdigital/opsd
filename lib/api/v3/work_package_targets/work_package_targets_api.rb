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
            authorize(:view_work_packages, global: true)
            #@work_package_targets = WorkPackageTarget.where('project_id = ? and work_package_id = ?', @project.id, @work_package.id)
            @work_package_targets = WorkPackageTarget.where('project_id = ? and work_package_id = ?', @work_package.project_id, @work_package.id)
          end

          get do
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
