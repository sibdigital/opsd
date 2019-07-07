#-- encoding: UTF-8
# This file written by XCC
# 22/06/2019

module BasicData
  class ProjectStatusSeeder < Seeder
    def seed_data!
      ProjectStatus.transaction do
        data.each do |attributes|
          ProjectStatus.create!(attributes)
        end
      end
    end

    def applicable?
      ProjectStatus.all.empty?
    end

    def not_applicable_message
      'Skipping project status as there are already some configured'
    end

    def data

      [
        { name: I18n.t(:default_project_status_not_start), position: 1, type: "ProjectStatus", active: true, is_default: true },
        { name: I18n.t(:default_project_status_in_work), position: 2, type: "ProjectStatus", active: true, is_default: false },
        { name: I18n.t(:default_project_status_ready_to_check), position: 4, type: "ProjectStatus", active: true, is_default: false },
        { name: I18n.t(:default_project_status_completed), position: 5, type: "ProjectStatus", active: true, is_default: false },
        { name: I18n.t(:default_project_status_cancel), position: 6, type: "ProjectStatus", active: true, is_default: false },
        { name: I18n.t(:default_project_status_waiting), position: 7, type: "ProjectStatus", active: true, is_default: false }
      ]

    end

  end
end
