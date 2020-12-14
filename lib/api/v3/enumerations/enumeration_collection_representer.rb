require 'roar/decorator'
require 'roar/json'
require 'roar/json/collection'
require 'roar/json/hal'
module API
  module V3
    module Enumerations
      class EnumerationCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::Enumerations::EnumerationRepresenter
      end
    end
  end
end
