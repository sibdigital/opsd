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
  class WorkflowSeeder < Seeder
    def seed_data!
      colors = Color.all
      colors = colors.map { |c| { c.name =>  c.id } }.reduce({}, :merge)

      if WorkPackage.where(type_id: nil).any? || Journal::WorkPackageJournal.where(type_id: nil).any?
        # Fixes work packages that do not have a type yet. They receive the standard type.
        #
        # This can happen when an existing database, having timelines planning elements,
        # gets migrated. During the migration, the existing planning elements are converted
        # to work_packages. Because the existance of a standard type cannot be guaranteed
        # during the migration, such work packages receive a type_id of nil.
        #
        # Because all work packages that do not have a type yet should always have had one
        # (from todays standpoint). The assignment is done covertedly.

        WorkPackage.transaction do
          green_color = colors[I18n.t(:default_color_green_light)]
          standard_type = Type.find_or_create_by(is_standard: true,
                                                 name: 'none',
                                                 position: 0,
                                                 color_id: green_color,
                                                 is_default: true,
                                                 is_in_roadmap: true,
                                                 is_milestone: false)

          [WorkPackage, Journal::WorkPackageJournal].each do |klass|
            klass.where(type_id: nil).update_all(type_id: standard_type.id)
          end
        end
      end

      if Type.where(is_standard: false).any? || Status.any? || Workflow.any?
        puts '   *** Skipping types, statuses and workflows as there are already some configured'
      elsif Role.where(name: I18n.t(:default_role_member)).empty? ||
            Role.where(name: I18n.t(:default_role_project_admin)).empty?

        puts '   *** Skipping types, statuses and workflows as the required roles do not exist'
      else
        member = Role.where(name: I18n.t(:default_role_member)).first
        manager = Role.where(name: I18n.t(:default_role_project_admin)).first

        puts '   ↳ Types'
        TypeSeeder.new.seed!

        puts '   ↳ Statuses'
        StatusSeeder.new.seed!

        # Workflow - Each type has its own workflow
        workflows.each { |type_id, statuses_for_type|
          statuses_for_type.each { |old_status|
            statuses_for_type.each { |new_status|
              [manager.id, member.id].each { |role_id|
                Workflow.create type_id: type_id,
                                role_id: role_id,
                                old_status_id: old_status.id,
                                new_status_id: new_status.id
              }
            }
          }
        }
      end
    end

    def workflows
      types = Type.all
      types = types.map { |t| { t.name =>  t.id } }.reduce({}, :merge)

      new         = Status.find_by(name: I18n.t(:default_status_not_start))
      in_progress         = Status.find_by(name: I18n.t(:default_status_in_work))
      closed         = Status.find_by(name: I18n.t(:default_status_completed))
      rejected         = Status.find_by(name: I18n.t(:default_status_cancelled))
      on_hold         = Status.find_by(name: I18n.t(:default_status_postpone))
      in_testing         = Status.find_by(name: I18n.t(:default_status_on_check))

      # new              = Status.find_by(name: I18n.t(:default_status_new))
      # in_specification = Status.find_by(name: I18n.t(:default_status_in_specification))
      # specified        = Status.find_by(name: I18n.t(:default_status_specified))
      # confirmed        = Status.find_by(name: I18n.t(:default_status_confirmed))
      # to_be_scheduled  = Status.find_by(name: I18n.t(:default_status_to_be_scheduled))
      # scheduled        = Status.find_by(name: I18n.t(:default_status_scheduled))
      # in_progress      = Status.find_by(name: I18n.t(:default_status_in_progress))
      # in_development   = Status.find_by(name: I18n.t(:default_status_in_development))
      # developed        = Status.find_by(name: I18n.t(:default_status_developed))
      # in_testing       = Status.find_by(name: I18n.t(:default_status_in_testing))
      # tested           = Status.find_by(name: I18n.t(:default_status_tested))
      # test_failed      = Status.find_by(name: I18n.t(:default_status_test_failed))
      # closed           = Status.find_by(name: I18n.t(:default_status_closed))
      # on_hold          = Status.find_by(name: I18n.t(:default_status_on_hold))
      # rejected         = Status.find_by(name: I18n.t(:default_status_rejected))

      {
        types[I18n.t(:default_type_task)]       => [new, in_progress, closed, rejected, on_hold, in_testing],
        types[I18n.t(:default_type_milestone)]  => [new, in_progress, closed, rejected, on_hold, in_testing],
        types[I18n.t(:default_type_result)]  => [new, in_progress, closed, rejected, on_hold, in_testing],
        #+-tan 01.07.2019
        # types[I18n.t(:default_type_milestone)]  => [new, in_progress, closed, rejected, on_hold, in_testing],
        # types[I18n.t(:default_type_phase)]      => [new, in_progress, closed, rejected, on_hold, in_testing],
        # types[I18n.t(:default_type_feature)]    => [new, in_progress, closed, rejected, on_hold, in_testing],
        # types[I18n.t(:default_type_epic)]       => [new, in_progress, closed, rejected, on_hold, in_testing],
        # types[I18n.t(:default_type_user_story)] => [new, in_progress, closed, rejected, on_hold, in_testing],
        # types[I18n.t(:default_type_bug)]        => [new, in_progress, closed, rejected, on_hold, in_testing]
      }
    end
  end
end
