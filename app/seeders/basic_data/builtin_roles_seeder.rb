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
  class BuiltinRolesSeeder < Seeder
    def seed_data!
      data.each do |attributes|
        unless Role.find_by(builtin: attributes[:builtin]).nil?
          puts "   *** Skipping built in role #{attributes[:name]} - already exists"
          next
        end
        puts attributes
        Role.create(attributes)
      end
    end

    def data
      [
        { name: I18n.t(:default_role_non_member), position: 0, builtin: Role::BUILTIN_NON_MEMBER },
        { name: I18n.t(:default_role_anonymous),  position: 1, builtin: Role::BUILTIN_ANONYMOUS  },
        { name: I18n.t(:default_role_project_admin), builtin: Role::BUILTIN_PROJECT_ADMIN },
        { name: I18n.t(:default_role_project_curator), builtin: Role::BUILTIN_PROJECT_CURATOR },
        { name: I18n.t(:default_role_project_customer), builtin: Role::BUILTIN_PROJECT_CUSTOMER },
        { name: I18n.t(:default_role_project_office_manager), builtin: Role::BUILTIN_PROJECT_OFFICE_MANAGER },
        { name: I18n.t(:default_role_project_activity_coordinator), builtin: Role::PROJECT_ACTIVITY_COORDINATOR },
        { name: I18n.t(:default_role_project_office_coordinator), builtin: Role::BUILTIN_PROJECT_OFFICE_COORDINATOR },
        { name: I18n.t(:default_role_events_responsible), builtin: Role::BUILTIN_EVENTS_RESPONSIBLE },
        { name: I18n.t(:default_role_project_head), builtin: Role::BUILTIN_PROJECT_HEAD },
        { name: I18n.t(:default_role_project_office_admin), builtin: Role::BUILTIN_PROJECT_OFFICE_ADMIN }
      ]
    end
  end
end
