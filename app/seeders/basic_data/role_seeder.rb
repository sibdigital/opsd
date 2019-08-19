#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++
module BasicData
  class RoleSeeder < Seeder
    def seed_data!
      Role.transaction do
        roles.each do |attributes|
          Role.create!(attributes)
        end

        builtin_roles.each do |attributes|
          puts attributes[:name]
          Role.find_by!(name: attributes[:name]).update_attributes(attributes)
        end
     end
    end

    def applicable?
      Role.where(builtin: false).empty?
    end

    def not_applicable_message
      'Skipping roles as there are already some configured'
    end

    def roles
      #+-tan
      # удалена роль участника проекта и администратора проектного офиса
      # т.к. участник - это ответственный за блок мероприятий
      # администратор проектного офиса - это координатор от проектного офиса
     [#project_admin,
      #member,
      reader,
      #zbd( +tan 2019.07.05
      #project_curator, project_customer, project_office_manager, project_activity_coordinator,
      #project_office_coordinator, project_office_admin, project_head, events_responsible
      project_admin, project_curator, project_customer,
      project_office_manager, project_activity_coordinator, project_office_coordinator,
      events_responsible, project_head, #, project_office_admin
      #zbd(
      glava_regiona,
      glava_regiona_global,
      project_office_coordinator_global,
      project_office_manager_global,
      project_activity_coordinator_global
      #)
     #)
      ]
    end

    # 2019.07.05. tan: добавлены роли по умолчанию
    def builtin_roles
      [non_member, anonymous
      # , project_admin, project_curator, project_customer,
      # project_office_manager, project_activity_coordinator, project_office_coordinator,
      # events_responsible, project_head, project_office_admin
      ]

    end

    def member
     { name: I18n.t(:default_role_member), position: 3, permissions: [
          :view_work_packages,
          :export_work_packages,
          :add_work_packages,
          :move_work_packages,
          :edit_work_packages,
          :add_work_package_notes,
          :edit_own_work_package_notes,
          :manage_work_package_relations,
          :manage_subtasks,
          :manage_public_queries,
          :save_queries,
          :view_work_package_watchers,
          :add_work_package_watchers,
          :delete_work_package_watchers,
          :view_calendar,
          :comment_news,
          :manage_news,
          :log_time,
          :view_time_entries,
          :view_own_time_entries,
          :edit_own_time_entries,
          :view_timelines,
          :edit_timelines,
          :delete_timelines,
          :view_reportings,
          :edit_reportings,
          :delete_reportings,
          :manage_wiki,
          :manage_wiki_menu,
          :rename_wiki_pages,
          :change_wiki_parent_page,
          :delete_wiki_pages,
          :view_wiki_pages,
          :export_wiki_pages,
          :view_wiki_edits,
          :edit_wiki_pages,
          :delete_wiki_pages_attachments,
          :protect_wiki_pages,
          :list_attachments,
          :add_messages,
          :edit_own_messages,
          :delete_own_messages,
          :browse_repository,
          :view_changesets,
          :commit_access,
          :view_commit_author_statistics,
          :view_members
        ]
      }
    end

    def reader
      { name: I18n.t(:default_role_reader), position:4, permissions: [
          :view_work_packages,
          :add_work_package_notes,
          :edit_own_work_package_notes,
          :save_queries,
          :view_calendar,
          :comment_news,
          :view_timelines,
          :view_reportings,
          :view_wiki_pages,
          :export_wiki_pages,
          :list_attachments,
          :add_messages,
          :edit_own_messages,
          :delete_own_messages,
          :browse_repository,
          :view_changesets
        ]
      }
    end

    def project_admin
     { name: I18n.t(:default_role_project_admin), position: 5, permissions: Role.new.setable_permissions.map(&:name) }
    end

    #zbd(
    def project_curator
      { name: I18n.t(:default_role_project_curator), position: 6, permissions: [
        :view_work_packages,
        :export_work_packages,
        :add_work_packages,
        :move_work_packages,
        :edit_work_packages,
        :add_work_package_notes,
        :edit_own_work_package_notes,
        :manage_work_package_relations,
        :manage_subtasks,
        :manage_public_queries,
        :save_queries,
        :view_work_package_watchers,
        :add_work_package_watchers,
        :delete_work_package_watchers,
        :view_calendar,
        :comment_news,
        :manage_news,
        :log_time,
        :view_time_entries,
        :view_own_time_entries,
        :edit_own_time_entries,
        :view_timelines,
        :edit_timelines,
        :delete_timelines,
        :view_reportings,
        :edit_reportings,
        :delete_reportings,
        :manage_wiki,
        :manage_wiki_menu,
        :rename_wiki_pages,
        :change_wiki_parent_page,
        :delete_wiki_pages,
        :view_wiki_pages,
        :export_wiki_pages,
        :view_wiki_edits,
        :edit_wiki_pages,
        :delete_wiki_pages_attachments,
        :protect_wiki_pages,
        :list_attachments,
        :add_messages,
        :edit_own_messages,
        :delete_own_messages,
        :browse_repository,
        :view_changesets,
        :commit_access,
        :view_commit_author_statistics,
        :view_members
      ]
      }
    end

    def project_customer
      { name: I18n.t(:default_role_project_customer), position: 7, permissions: [
        :view_work_packages,
        :export_work_packages,
        :add_work_packages,
        :move_work_packages,
        :edit_work_packages,
        :add_work_package_notes,
        :edit_own_work_package_notes,
        :manage_work_package_relations,
        :manage_subtasks,
        :manage_public_queries,
        :save_queries,
        :view_work_package_watchers,
        :add_work_package_watchers,
        :delete_work_package_watchers,
        :view_calendar,
        :comment_news,
        :manage_news,
        :log_time,
        :view_time_entries,
        :view_own_time_entries,
        :edit_own_time_entries,
        :view_timelines,
        :edit_timelines,
        :delete_timelines,
        :view_reportings,
        :edit_reportings,
        :delete_reportings,
        :manage_wiki,
        :manage_wiki_menu,
        :rename_wiki_pages,
        :change_wiki_parent_page,
        :delete_wiki_pages,
        :view_wiki_pages,
        :export_wiki_pages,
        :view_wiki_edits,
        :edit_wiki_pages,
        :delete_wiki_pages_attachments,
        :protect_wiki_pages,
        :list_attachments,
        :add_messages,
        :edit_own_messages,
        :delete_own_messages,
        :browse_repository,
        :view_changesets,
        :commit_access,
        :view_commit_author_statistics,
        :view_members
      ]
      }
    end

    def project_office_manager
      { name: I18n.t(:default_role_project_office_manager), position: 8, permissions: [
        :view_work_packages,
        :export_work_packages,
        :add_work_packages,
        :move_work_packages,
        :edit_work_packages,
        :add_work_package_notes,
        :edit_own_work_package_notes,
        :manage_work_package_relations,
        :manage_subtasks,
        :manage_public_queries,
        :save_queries,
        :view_work_package_watchers,
        :add_work_package_watchers,
        :delete_work_package_watchers,
        :view_calendar,
        :comment_news,
        :manage_news,
        :log_time,
        :view_time_entries,
        :view_own_time_entries,
        :edit_own_time_entries,
        :view_timelines,
        :edit_timelines,
        :delete_timelines,
        :view_reportings,
        :edit_reportings,
        :delete_reportings,
        :manage_wiki,
        :manage_wiki_menu,
        :rename_wiki_pages,
        :change_wiki_parent_page,
        :delete_wiki_pages,
        :view_wiki_pages,
        :export_wiki_pages,
        :view_wiki_edits,
        :edit_wiki_pages,
        :delete_wiki_pages_attachments,
        :protect_wiki_pages,
        :list_attachments,
        :add_messages,
        :edit_own_messages,
        :delete_own_messages,
        :browse_repository,
        :view_changesets,
        :commit_access,
        :view_commit_author_statistics,
        :view_members
      ]}
    end

    def project_activity_coordinator
      { name: I18n.t(:default_role_project_activity_coordinator), position: 9, permissions: [
        :view_work_packages,
        :export_work_packages,
        :add_work_packages,
        :move_work_packages,
        :edit_work_packages,
        :add_work_package_notes,
        :edit_own_work_package_notes,
        :manage_work_package_relations,
        :manage_subtasks,
        :manage_public_queries,
        :save_queries,
        :view_work_package_watchers,
        :add_work_package_watchers,
        :delete_work_package_watchers,
        :view_calendar,
        :comment_news,
        :manage_news,
        :log_time,
        :view_time_entries,
        :view_own_time_entries,
        :edit_own_time_entries,
        :view_timelines,
        :edit_timelines,
        :delete_timelines,
        :view_reportings,
        :edit_reportings,
        :delete_reportings,
        :manage_wiki,
        :manage_wiki_menu,
        :rename_wiki_pages,
        :change_wiki_parent_page,
        :delete_wiki_pages,
        :view_wiki_pages,
        :export_wiki_pages,
        :view_wiki_edits,
        :edit_wiki_pages,
        :delete_wiki_pages_attachments,
        :protect_wiki_pages,
        :list_attachments,
        :add_messages,
        :edit_own_messages,
        :delete_own_messages,
        :browse_repository,
        :view_changesets,
        :commit_access,
        :view_commit_author_statistics,
        :view_members
      ]}
    end

    def project_office_coordinator
      { name: I18n.t(:default_role_project_office_coordinator), position: 10, permissions: Role.new.setable_permissions.map(&:name) }
    end

    def events_responsible
      { name: I18n.t(:default_role_events_responsible), position: 11, permissions: Role.new.setable_permissions.map(&:name) }
    end

    def project_head
      { name: I18n.t(:default_role_project_head), position: 12, permissions: Role.new.setable_permissions.map(&:name) }
    end

    def project_office_admin
      { name: I18n.t(:default_role_project_office_admin), position: 13, permissions: Role.new.setable_permissions.map(&:name) }
    end

    def glava_regiona
      { name: I18n.t(:default_role_glava_regiona), position: 14, permissions: Role.new.setable_permissions.map(&:name) }
    end

    # глобальные роли
    def glava_regiona_global
      { name: I18n.t(:default_role_glava_regiona_global), position: 15, permissions: Role.new.setable_permissions.map(&:name), type: 'GlobalRole' }
    end

    def project_office_coordinator_global
      { name: I18n.t(:default_role_project_office_coordinator_global), position: 16, permissions: Role.new.setable_permissions.map(&:name), type: 'GlobalRole' }
    end

    def project_activity_coordinator_global
      { name: I18n.t(:default_role_project_activity_coordinator_global), position: 17, permissions: [
        :view_work_packages,
        :export_work_packages,
        :add_work_packages,
        :move_work_packages,
        :edit_work_packages,
        :add_work_package_notes,
        :edit_own_work_package_notes,
        :manage_work_package_relations,
        :manage_subtasks,
        :manage_public_queries,
        :save_queries,
        :view_work_package_watchers,
        :add_work_package_watchers,
        :delete_work_package_watchers,
        :view_calendar,
        :comment_news,
        :manage_news,
        :log_time,
        :view_time_entries,
        :view_own_time_entries,
        :edit_own_time_entries,
        :view_timelines,
        :edit_timelines,
        :delete_timelines,
        :view_reportings,
        :edit_reportings,
        :delete_reportings,
        :manage_wiki,
        :manage_wiki_menu,
        :rename_wiki_pages,
        :change_wiki_parent_page,
        :delete_wiki_pages,
        :view_wiki_pages,
        :export_wiki_pages,
        :view_wiki_edits,
        :edit_wiki_pages,
        :delete_wiki_pages_attachments,
        :protect_wiki_pages,
        :list_attachments,
        :add_messages,
        :edit_own_messages,
        :delete_own_messages,
        :browse_repository,
        :view_changesets,
        :commit_access,
        :view_commit_author_statistics,
        :view_members
      ],
        type: 'GlobalRole'
      }
    end

    def project_office_manager_global
      { name: I18n.t(:default_role_project_office_manager_global), position: 18, permissions: [
        :view_work_packages,
        :export_work_packages,
        :add_work_packages,
        :move_work_packages,
        :edit_work_packages,
        :add_work_package_notes,
        :edit_own_work_package_notes,
        :manage_work_package_relations,
        :manage_subtasks,
        :manage_public_queries,
        :save_queries,
        :view_work_package_watchers,
        :add_work_package_watchers,
        :delete_work_package_watchers,
        :view_calendar,
        :comment_news,
        :manage_news,
        :log_time,
        :view_time_entries,
        :view_own_time_entries,
        :edit_own_time_entries,
        :view_timelines,
        :edit_timelines,
        :delete_timelines,
        :view_reportings,
        :edit_reportings,
        :delete_reportings,
        :manage_wiki,
        :manage_wiki_menu,
        :rename_wiki_pages,
        :change_wiki_parent_page,
        :delete_wiki_pages,
        :view_wiki_pages,
        :export_wiki_pages,
        :view_wiki_edits,
        :edit_wiki_pages,
        :delete_wiki_pages_attachments,
        :protect_wiki_pages,
        :list_attachments,
        :add_messages,
        :edit_own_messages,
        :delete_own_messages,
        :browse_repository,
        :view_changesets,
        :commit_access,
        :view_commit_author_statistics,
        :view_members
      ],
        type: 'GlobalRole'
      }
    end

    # )

    def non_member
      { name: I18n.t(:default_role_non_member), permissions: [
        #:view_work_packages,
        #:view_calendar,
        #:comment_news,
        #:browse_repository,
        #:view_changesets,
        #:view_wiki_pages
      ]
      }
    end

    def anonymous
      { name: I18n.t(:default_role_anonymous), permissions: [
        #:view_work_packages,
        #:browse_repository,
        #:view_changesets,
        #:view_wiki_pages
      ]
      }
    end
  end
end

