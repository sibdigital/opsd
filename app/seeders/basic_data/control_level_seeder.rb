
#-- encoding: UTF-8
# This file written by knm
# 22/06/2019

module BasicData
  class ControlLevelSeeder < Seeder
    def seed_data!
      ControlLevel.transaction do
        data.each do |attributes|
          ControlLevel.create!(attributes)
        end
      end
    end

    def applicable?
      ControlLevel.all.empty?
    end

    def not_applicable_message
      'Skipping levels of control as there are already some configured'
    end

    def data

      [
        { name: "Ответственный за блок мер-тий.", code: 1},
        { name: "Администратор.", code: 2},
        { name: "Руководитель проекта.", code: 3},
        { name: "Куратор.", code: 4}
      ]

    end

  end
end

