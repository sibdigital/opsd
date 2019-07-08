#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/targets/target_representer'
require 'api/v3/targets/target_collection_representer'

module API
  module V3
    module Targets
      class TargetsAPI < ::API::OpenProjectAPI
        resources :targets do
          before do
            authorize(:view_work_packages, global: true)
            @targets = Target.where('project_id = ?', @project.id)
          end

          get do
            TargetCollectionRepresenter.new(@targets,
                                            api_v3_paths.targets,
                                            current_user: current_user)
          end

          route_param :id do
            before do
              @target = Target.find(params[:id])
            end

            get do
              TargetRepresenter.new(@target, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
