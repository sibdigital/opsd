require 'roar/decorator'
require 'roar/json/hal'
module API
  module V3
    module Enumerations
      class EnumerationRepresenter < ::API::Decorators::Single
        def _type
          'Enumeration'
        end

        property :id, render_nil: false
        property :name, render_nil: true
        property :position, render_nil: true
        property :is_default, render_nil: true
        property :type, render_nil: true
        property :active, render_nil: true
      end
    end
  end
end
