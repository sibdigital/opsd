module API
  module V3
    module Colorlight
      class ColorlightAPI < ::API::OpenProjectAPI
        resources :colorlight do
          get do
            @ready = ::Colorlight.create_xlsx(params['type'].to_i)
            { path: @ready }
          end
        end
      end
    end
  end
end

