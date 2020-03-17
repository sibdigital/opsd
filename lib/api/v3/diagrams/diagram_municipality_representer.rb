module API
  module V3
    module Diagrams
      class DiagramMunicipalityRepresenter < ::API::Decorators::Single
        include ::API::V3::Utilities::RoleHelper

        def initialize(params:, current_user:, global_role:)
          @name = params[:name]
          @performance = params[:performance]
          @organization = params[:organization]
          @current_user = current_user
          @global_role = global_role
          @project = params[:project]
          @raionId = params[:raionId]
        end

        property :national_projects,
                 getter: ->(*) {
                   "Hello World"
                 }

        def _type
          'DiagramMunicipality'
        end
      end
    end
  end
end

