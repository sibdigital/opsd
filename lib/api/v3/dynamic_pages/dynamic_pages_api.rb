require 'api/v3/dynamic_pages/dynamic_pages_representer'
module API
  module V3
    module DynamicPages
      class DynamicPagesAPI < ::API::OpenProjectAPI
        resources :dynamic_pages do
          helpers do
            def dynamic_page
              DynamicPage.find(1)
            end
          end
          route_param :id do
            get do
              ::API::V3::DynamicPages::DynamicPageRepresenter.new(dynamic_page,
                                                              current_user: current_user,
                                                              embed_links: true)
            end

            mount ::API::V3::Attachments::AttachmentsByDynamicPageAPI
          end
        end
      end
    end
  end
end
