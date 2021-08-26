require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module DynamicPages
      class DynamicPageRepresenter < ::API::Decorators::Single
        include API::Decorators::LinkedResource
        include API::Caching::CachedRepresenter
        include ::API::V3::Attachments::AttachableRepresenterMixin
        property :id
        property :content
        def _type
          'DynamicPage'
        end
      end
    end
  end
end
