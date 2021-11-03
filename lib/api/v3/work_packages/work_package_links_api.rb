module API
  module V3
    module WorkPackages
      class WorkPackageLinksAPI < ::API::OpenProjectAPI
        helpers ::API::Utilities::ParamsHelper

        resources :work_package_links do
          get do
            work_package_links = if params[:id].present?
                                   WorkPackageLink.where('work_package_id = ?', params[:id])
                                 end
            API::V3::WorkPackageLinks::WorkPackageLinkCollectionRepresenter.new(work_package_links,
                                                     api_v3_paths.work_package_links(params[:work_package_id]),
                                                     current_user: current_user)
          end

          post do
            work_package_links = if params[:work_package_id].present?
                                   WorkPackageLink.where('work_package_id = ?', params[:work_package_id])
                                 end
            API::V3::WorkPackageLinks::WorkPackageLinkCollectionRepresenter.new(work_package_links,
                                                     api_v3_paths.work_package_links(params[:work_package_id]),
                                                     current_user: current_user)
          end
        end
      end
    end
  end
end

