#-- encoding: UTF-8

#-- TAN

#++

module API
  module V3
    module Queries
      module Schemas
        class RaionFilterDependencyRepresenter <
          FilterDependencyRepresenter

          # def json_cache_key
          #   super + [filter.raion.id]
          # end

          def href_callback
            api_v3_paths.raions
          end

          def type
            "[]Raion"
          end
        end
      end
    end
  end
end
