require 'api/v3/work_package_links/work_package_link_representer'
require 'api/v3/work_package_links/work_package_link_collection_representer'
module API
  module V3
    module WorkPackageLinks
      class WorkPackageLinksAPI < ::API::OpenProjectAPI
        resources :links do
          get do
            WorkPackageLinkCollectionRepresenter.new(WorkPackageLink.all,
                                                     api_v3_paths.links,
                                                     current_user: current_user)
          end
          post do
            link = WorkPackageLink.new
            link.link = params[:link]
            link.name = params[:name]
            link.author_id = current_user.id
            link.work_package_id = params[:work_package_id]
            link.save
            WorkPackageLinkRepresenter.new(link,
                                           current_user: current_user,
                                           embed_links: true)
          end
          route_param :id do
            get do
              WorkPackageLinkRepresenter.new(WorkPackageLink.find_by_id!(params[:id]),
                                             current_user: current_user,
                                             embed_links: true)
            end
            patch do
              WorkPackageLink.update(params[:id], params)
            end
            delete do
              WorkPackageLink.destroy(params[:id])
              status 204
            end
          end
        end
      end
    end
  end
end
