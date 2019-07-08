#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Targets
      class TargetRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        link :self do
          {
            href: api_v3_paths.target(represented.id),
            title: represented.name
          }
        end

        link :project do
          {
            href: api_v3_paths.project(represented.project.id),
            title: represented.project.name
          }
        end
        property :id, render_nil: true
        property :name, render_nil: true

        def _type
          'Target'
        end
      end
    end
  end
end
