#-- encoding: UTF-8
# This file written by BBM
# 25/04/2019

module BasicData
  class ProjectSectionSeeder < Seeder
    def seed_data!
      ProjectSection.transaction do
        data.each do |attributes|
          ProjectSection.create!(attributes)
        end
      end
    end

    def applicable?
      ProjectSection.all.empty?
    end

    def not_applicable_message
      'Skipping project section as there are already some configured'
    end

    def data
      [
        { name: I18n.t(:default_project_section_1), position: 1, is_default: true },
        { name: I18n.t(:default_project_section_2), position: 2, is_default: false },
        { name: I18n.t(:default_project_section_3), position: 3, is_default: false },
        { name: I18n.t(:default_project_section_4), position: 4, is_default: false },
        { name: I18n.t(:default_project_section_5), position: 5, is_default: false },
        { name: I18n.t(:default_project_section_6), position: 6, is_default: false },
        { name: I18n.t(:default_project_section_7), position: 7, is_default: false },
        { name: I18n.t(:default_project_section_8), position: 8, is_default: false }
      ]
    end
  end
end
