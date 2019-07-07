#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Organizations
      class OrganizationRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        self_link title_getter: ->(*) { represented.name }

        property :id, render_nil: true
        property :name

        def _type
          'Organization'
        end
      end
    end
  end
end
