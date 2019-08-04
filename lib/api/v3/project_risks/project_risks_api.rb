#-- copyright
#zbd
#++

require 'api/v3/project_risks/project_risk_representer'
require 'api/v3/project_risks/project_risk_collection_representer'

module API
  module V3
    module ProjectRisks
      class ProjectRisksAPI < ::API::OpenProjectAPI
        resources :project_risks do
          get do
            @project_risks =  if params['project_id'].present?
                        ProjectRisk.where(project_id: params['project_id'])
                      else
                        ProjectRisk.all
                      end
            ProjectRiskCollectionRepresenter.new(@project_risks,
                                             api_v3_paths.project_risks,
                                             page: 1,
                                             per_page: 20,
                                             current_user: current_user)
          end

          route_param :id do
            before do
              @project_risk = ProjectRisk.find(params[:id])
            end

            get do
              ProjectRiskRepresenter.new(@project_risk, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
