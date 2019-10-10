#-- encoding: UTF-8
#by tan
#++

require 'api/v3/periods/period_representer'
require 'api/v3/periods/period_collection_representer'

module API
  module V3
    module Periods
      class PeriodsAPI < ::API::OpenProjectAPI
        resources :periods do
          before do
            authorize(:view_work_packages, global: true)
            @periods = Period.all
          end

          get do
            PeriodCollectionRepresenter.new(@periods,
                                           api_v3_paths.periods,
                                           current_user: current_user)
          end

          route_param :id do
            before do
              @period = Period.find(params[:id])
            end
            get do
              PeriodRepresenter.new(@period, current_user: current_user)
            end
          end
        end
      end
    end
  end
end

