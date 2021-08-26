#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/contracts/contract_representer'
require 'api/v3/contracts/contract_collection_representer'

module API
  module V3
    module Contracts
      class ContractsAPI < ::API::OpenProjectAPI
        resources :contracts do
          before do
            authorize(:view_work_packages, global: true)
            if params[:project_id]
              @contracts = Contract.where(project_id: params[:project_id])
            else
              @contracts = Contract.all
            end
          end

          get do
            ContractCollectionRepresenter.new(@contracts,
                                            api_v3_paths.contracts,
                                            current_user: current_user)
          end

          route_param :id do
            before do
              @contract = Contract.find(params[:id])
            end

            get do
              ContractRepresenter.new(@contract, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
