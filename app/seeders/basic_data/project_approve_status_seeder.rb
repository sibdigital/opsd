#-- encoding: UTF-8
# This file written by XCC
# 22/06/2019

module BasicData
  class ProjectApproveStatusSeeder < Seeder
    def seed_data!
      ProjectApproveStatus.transaction do
        data.each do |attributes|
          ProjectApproveStatus.create!(attributes)
        end
      end
    end

    def applicable?
      ProjectApproveStatus.all.empty?
    end

    def not_applicable_message
      'Skipping project approve status as there are already some configured'
    end

    def data

      [
        { name: I18n.t(:default_project_approve_status_init), position: 1, type: "ProjectApproveStatus", active: true, is_default: true},
        { name: I18n.t(:default_project_approve_status_approve_project_head), position: 2, type: "ProjectApproveStatus", active: true, is_default: false },
        { name: I18n.t(:default_project_approve_status_agreed_project_office_coordinator), position: 4, type: "ProjectApproveStatus", active: true , is_default: false},
        { name: I18n.t(:default_project_approve_status_agreed_project_office_manager), position: 5, type: "ProjectApproveStatus", active: true, is_default: false },
        { name: I18n.t(:default_project_approve_status_approve_curator), position: 6, type: "ProjectApproveStatus", active: true, is_default: false },
        { name: I18n.t(:default_project_approve_status_approve_glava), position: 7, type: "ProjectApproveStatus", active: true, is_default: false }
      ]

    end

  end
end
