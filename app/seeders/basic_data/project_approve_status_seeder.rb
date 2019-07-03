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
        { name: "инициирован", position: 1, type: "ProjectApproveStatus", active: true },
        { name: "утвержден руководителем проекта", position: 2, type: "ProjectApproveStatus", active: true },
        { name: "согласован координатором Проектного офиса", position: 4, type: "ProjectApproveStatus", active: true },
        { name: "утвержден руководителем Проектного офиса", position: 5, type: "ProjectApproveStatus", active: true },
        { name: "утвержден куратором проекта", position: 6, type: "ProjectApproveStatus", active: true },
        { name: "утвержден Главой", position: 7, type: "ProjectApproveStatus", active: true }
      ]

    end

  end
end
