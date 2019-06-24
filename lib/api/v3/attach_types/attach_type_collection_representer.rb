#-- encoding: UTF-8
# This file written by BBM
# 24/06/2019
module API
  module V3
    module AttachTypes
      class AttachTypeCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        element_decorator ::API::V3::AttachTypes::AttachTypeRepresenter
      end
    end
  end
end
