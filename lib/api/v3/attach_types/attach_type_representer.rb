#-- encoding: UTF-8
# This file written by BBM
# 24/06/2019
require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module AttachTypes
      class AttachTypeRepresenter < ::API::Decorators::Single
        include API::Caching::CachedRepresenter

        self_link

        property :id, render_nil: true
        property :name
        property :position
        property :is_default
        property :active, as: :isActive

        def _type
          'AttachType'
        end
      end
    end
  end
end
