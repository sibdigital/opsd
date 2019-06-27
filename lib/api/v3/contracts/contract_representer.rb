#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Contracts
      class ContractRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        #self_link title_getter: ->(*) { represented.contract_subject }
        link :self do
          {
            href: api_v3_paths.contract(represented.id),
            title: represented.contract_subject
          }
        end

        property :id, render_nil: true
        property :contract_subject
        property :contract_num

        def _type
          'Contract'
        end
      end
    end
  end
end
