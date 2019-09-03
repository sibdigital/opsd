
module API
  module V3
    module Utilities
      module RoleHelper
        extend Grape::API::Helpers

        def which_role(project, current_user, global_role)
          @see_all_roles ||= see_all_roles
          @see_all_roles[global_role] || current_user.roles_for_project(project).find do |e|
            e.id.to_s == global_role and (e.name == I18n.t(:default_role_project_curator) or e.name == I18n.t(:default_role_project_head) or e.name == I18n.t(:default_role_project_office_coordinator))
          end
        end

        private
        def see_all_roles
          roles = Hash.new
          Role.all.map do |role|
            roles[role.id.to_s] = role if role.name == I18n.t(:default_role_glava_regiona)
            roles[role.id.to_s] = role if role.name == I18n.t(:default_role_project_activity_coordinator)
            roles[role.id.to_s] = role if role.name == I18n.t(:default_role_project_office_manager)
          end
          roles
        end
      end
    end
  end
end
