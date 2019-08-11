#-- encoding: UTF-8

#-- TAN

#++

module API
  module V3
    module Queries
      module Schemas
        class OrganizationFilterDependencyRepresenter <
          FilterDependencyRepresenter

          # def json_cache_key
          #   super + [filter.raion.id]
          # end

          def href_callback
            api_v3_paths.organizations
          end

          def type
            "[]Organization"
          end
        end
      end
    end
  end
end
