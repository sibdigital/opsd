module API
  module V3
    module WPAssigned
      class WPAssignedAPI < ::API::OpenProjectAPI
        resources :wp_assigned do
          route_param :wp do
            before do
              @work_package = WorkPackage.find(params[:wp])
            end
            route_param :as do
              before do
                @work_package.update(assigned_to_id: params[:as])
              end
              get do
                message_assigned = 'Информация обновлена'
                message_assigned
              end
            end
          end
        end
      end
    end
  end
end
