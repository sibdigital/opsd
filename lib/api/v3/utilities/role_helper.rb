
module API
  module V3
    module Utilities
      module RoleHelper
        extend Grape::API::Helpers

        # project - проект
        # current_user - текущий пользователь
        # global_role - какая у него счс глобальная роль, по ней и определяем что он видит на рабочих столах
        def which_role(project, current_user, global_role)
          current_user.roles_for_project(project)
          # Rails.logger.info("project#{project.id} current_user: #{current_user.id} global_role: #{global_role}")
          # @see_all_roles ||= see_all_roles
          # @see_all_roles[global_role] || current_user.roles_for_project(project).find do |e|
          #   # функция которая определяет, укладывается ли проект в данную выбранную роль
          #   e.id.to_s == global_role and (e.name == I18n.t(:default_role_project_curator) or e.name == I18n.t(:default_role_project_head) or
          #     e.name == I18n.t(:default_role_project_office_coordinator) or e.name == I18n.t(:default_role_project_admin) or
          #     e.name == I18n.t(:default_role_member) or e.name == I18n.t(:default_role_ispolnitel))
          # end
        end

        def which_roles(projects, current_user)
          slq =  <<-SQL
            select distinct r.*
            from (
                   SELECT "roles".*
                   FROM "roles"
                          INNER JOIN "member_roles" ON "roles"."id" = "member_roles"."role_id"
                          inner join (
                     select id
                     from members as m
                     where m.project_id in (?)
                       and user_id = ?
                   ) as mp
                    on member_roles.member_id = mp.id
            ) as r
          SQL
          roles = Role.find_by_sql([slq, projects.map{|p| p.id}, current_user.id])
          roles
        end

        private
        # def see_all_roles
        #   roles = Hash.new
        #   Role.all.map do |role|
        #     roles[role.id.to_s] = role if role.name == I18n.t(:default_role_glava_regiona)
        #     roles[role.id.to_s] = role if role.name == I18n.t(:default_role_project_activity_coordinator)
        #     roles[role.id.to_s] = role if role.name == I18n.t(:default_role_project_office_manager)
        #     roles[role.id.to_s] = role if role.name == I18n.t(:default_role_project_office_coordinator)
        #   end
        #   Rails.logger.info("project#{roles}")
        #   roles
        # end
      end
    end
  end
end
