module API
  module V3
    module Attachments
      class AttachmentsByDynamicPageAPI < ::API::OpenProjectAPI
        resources :attachments do
          helpers API::V3::Attachments::AttachmentsByContainerAPI::Helpers

          helpers do
            def container
              dynamic_page
            end

            def get_attachment_self_path
              api_v3_paths.attachments_by_dynamic_page(container.id)
            end
          end

          get &API::V3::Attachments::AttachmentsByContainerAPI.read
          post &API::V3::Attachments::AttachmentsByContainerAPI.create()
        end
      end
    end
  end
end

