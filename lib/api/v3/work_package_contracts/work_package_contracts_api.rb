require 'api/v3/work_package_contracts/work_package_contract_representer'
require 'api/v3/work_package_contracts/work_package_contract_collection_representer'
module API
  module V3
    module WorkPackageContracts
      class WorkPackageContractsAPI < ::API::OpenProjectAPI
        resources :work_package_contracts do
          before do
            @work_package_contracts = if params[:work_package_id].nil?
                                       WorkPackageContract.all
                                     else
                                       WorkPackageContract
                                           .where('work_package_id = ?', params[:work_package_id])
                                           .order('id asc')
                                     end
          end
          get do
            WorkPackageContractCollectionRepresenter.new(@work_package_contracts,
                                                     api_v3_paths.work_package_contracts,
                                                     current_user: current_user)
          end
          post do
            contract = WorkPackageContract.new
            contract.contract_id = params[:contract_id]
            contract.comment = params[:comment]
            contract.author_id = current_user.id
            contract.work_package_id = params[:work_package_id]
            contract.save
            WorkPackageContractRepresenter.new(contract,
                                               current_user: current_user)
          end
          route_param :id do
            get do
              WorkPackageContractRepresenter.new(WorkPackageContract.find(params[:id]),
                                             current_user: current_user)
            end
            patch do
              WorkPackageContract.update(params[:id], params)
            end
            delete do
              WorkPackageContract.destroy(params[:id])
              status 204
            end
          end
        end
      end
    end
  end
end

