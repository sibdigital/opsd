#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/organizations/organization_representer'
require 'api/v3/organizations/organization_collection_representer'

module API
  module V3
    module Organizations
      class OrganizationsAPI < ::API::OpenProjectAPI
        resources :organizations do
          before do
            authorize(:view_work_packages, global: true)
            @organizations = Organization.all
          end

          get do
            OrganizationCollectionRepresenter.new(@organizations,
                                              api_v3_paths.organizations,
                                              current_user: current_user)
          end

           route_param :id do
             before do
               @organization = Organization.find(params[:id])
             end
            get do
              OrganizationRepresenter.new(@organization, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
