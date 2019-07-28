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
            @wp_targets = WorkPackageTarget.where('project_id = ?', @project.id)
          end

          get do
            WorkPackageTargetCollectionRepresenter.new(@wp_targets,
                                           api_v3_paths.work_package_targets,
                                           current_user: current_user)
          end

          route_param :id do
            before do
              @wp_target = WorkPackageTarget.find(params[:id])
            end

            get do
              WorkPackageTargetRepresenter.new(@wp_target, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
