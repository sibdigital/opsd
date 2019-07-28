#-- encoding: UTF-8
# This file written by XCC
# 03/07/2019

module BasicData
  class TargetTypeSeeder < Seeder
    def seed_data!
      TargetType.transaction do
        data.each do |attributes|
          TargetType.create!(attributes)
        end
      end
    end

    def applicable?
      TargetType.all.empty?
    end

    def not_applicable_message
      'Skipping target types as there are already some configured'
    end

    def data

      [
        { name: "Цель", position: 1, type: "TargetType", active: true },
        { name: "Показатель", position: 2, type: "TargetType", active: true },
        { name: "Результат", position: 3, type: "TargetType", active: true }
      ]

    end

  end
end
