require 'roar/decorator'
require 'roar/json'
require 'roar/json/collection'
require 'roar/json/hal'

module API
  module V3
    module Meetings
      class MeetingCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::Meetings::MeetingRepresenter
      end
    end
  end
end
