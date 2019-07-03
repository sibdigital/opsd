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
        { name: "не начат", position: 1, type: "ProjectStatus", active: true },
        { name: "в работе", position: 2, type: "ProjectStatus", active: true },
        { name: "готов к проверке", position: 4, type: "ProjectStatus", active: true },
        { name: "завершен", position: 5, type: "ProjectStatus", active: true },
        { name: "отменен", position: 6, type: "ProjectStatus", active: true },
        { name: "отложен", position: 7, type: "ProjectStatus", active: true }
      ]

    end

  end
end
