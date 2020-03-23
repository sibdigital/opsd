module API
  module V3
    module WorkPackages
      class CompactWorkPackageCollectionRepresenter < ::API::Decorators::OffsetPaginatedCollection
        element_decorator ::API::V3::WorkPackages::CompactWorkPackageRepresenter

        def initialize(models,
                       self_link,
                       query: {},
                       project: nil,
                       page: nil,
                       per_page: nil,
                       current_user:)
          @project = project
          super(models,
                self_link,
                query: query,
                page: page,
                per_page: per_page,
                current_user: current_user)

          # In order to optimize performance we
          #   * override paged_models so that only the id is fetched from the
          #     scope (typically a query with a couple of includes for e.g.
          #     filtering), circumventing AR instantiation alltogether
          #   * use the ids to fetch the actual work packages with all the fields
          #     necessary for rendering the work packages in _elements
          #
          # This results in the weird flow where the scope is passed to super (models variable),
          # which calls the overriden paged_models method fetching the ids. In order to have
          # real AR objects again, we finally get the work packages we actually want to have
          # and set those to be the represented collection.
          # A potential ordering is reapplied to the work package collection in ruby.

          @represented = ::API::V3::WorkPackages::WorkPackageEagerLoadingWrapper.wrap(represented, current_user)
        end

        collection :elements,
                   getter: ->(*) {
                     represented.map do |model|
                       element_decorator.new(model, current_user: current_user)
                     end
                   },
                   exec_context: :decorator,
                   embedded: true

        def schema_pairs
          represented
              .map { |work_package| [work_package.project, work_package.type, work_package.available_custom_fields] }
              .uniq
        end

        def paged_models(models)
          models.page(@page).per_page(@per_page).pluck(:id)
        end

        def _type
          'CompactWorkPackageCollection'
        end

        attr_reader :project,
                    :embed_schemas
      end
    end
  end
end

