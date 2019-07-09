#-- encoding: UTF-8
# This file written by XCC
# 08/07/2019

module BasicData
  class ArbitaryObjectTypeSeeder < Seeder
    def seed_data!
      ArbitaryObjectType.transaction do
        data.each do |attributes|
          ArbitaryObjectType.create!(attributes)
        end
      end
    end

    def applicable?
      ArbitaryObjectType.all.empty?
    end

    def not_applicable_message
      'Skipping organization types as there are already some configured'
    end

    def data

      [
        { name: "Встреча", position: 1, type: "ArbitaryObjectType", active: true },
        { name: "Командировка", position: 2, type: "ArbitaryObjectType", active: true },
        { name: "Совещание", position: 3, type: "ArbitaryObjectType", active: true },
      ]

    end

  end
end
