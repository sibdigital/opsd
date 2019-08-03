#-- encoding: UTF-8

# by zbd
#++

require 'api/v3/head_performances/head_performance_representer'
require 'api/v3/head_performances/head_performance_collection_representer'

module API
  module V3
    module HeadPerformances
      class HeadPerformancesAPI < ::API::OpenProjectAPI
        resources :head_performances do
          before do
            authorize(:view_work_packages, global: true)
            @head_performances = HeadPerformanceIndicator.all.order(:sort_code)
          end

          get do
            HeadPerformanceCollectionRepresenter.new(@head_performances,
                                                     api_v3_paths.head_performances,
                                                     current_user: current_user)
          end

          route_param :id do
            before do
              @head_performance = HeadPerformanceIndicator.find(params[:id])
            end
            get do
              HeadPerformanceRepresenter.new(@head_performance, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
