#-- encoding: UTF-8
# This file written by XCC
# 03/07/2019

module BasicData
  class TargetStatusSeeder < Seeder
    def seed_data!
      TargetStatus.transaction do
        data.each do |attributes|
          TargetStatus.create!(attributes)
        end
      end
    end

    def applicable?
      TargetStatus.all.empty?
    end

    def not_applicable_message
      'Skipping organization types as there are already some configured'
    end

    def data

      [
        { name: "Выполнено без отклонений", position: 1, type: "TargetStatus", active: true },
        { name: "Выполнено с отклонениями", position: 2, type: "TargetStatus", active: true },
        { name: "Исполняется без отклонений", position: 3, type: "TargetStatus", active: true },
        { name: "Исполняется с отклонениями", position: 4, type: "TargetStatus", active: true },
        { name: "Исполняется с критическими отклонениями", position: 5, type: "TargetStatus", active: true },
        { name: "Нет сведений", position: 6, type: "TargetStatus", active: true },
        { name: "Прогнозные сведения", position: 7, type: "TargetStatus", active: true }
      ]

    end

  end
end
