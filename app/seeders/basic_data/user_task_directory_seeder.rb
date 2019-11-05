#-- encoding: UTF-8
# This file written by BAN
# 25/10/2019

module BasicData
  class UserTaskDirectorySeeder < Seeder
    def seed_data!
      UserTaskDirectory.transaction do
        data.each do |attributes|
          UserTaskDirectory.create!(attributes)
        end
      end
    end

    def applicable?
      UserTaskDirectory.all.empty?
    end

    def not_applicable_message
      'Skipping UserTaskDirectories types as there are already some configured'
    end

    def data

      [
        { name: "Производственные календари", position: 1, type: "UserTaskDirectory", active: true },
        { name: "Типовые риски", position: 2, type: "UserTaskDirectory", active: true },
        { name: "Типовые результаты", position: 3, type: "UserTaskDirectory", active: true },
        { name: "Уровни контроля", position: 4, type: "UserTaskDirectory", active: true },
        { name: "Перечисления", position: 5, type: "UserTaskDirectory", active: true },
        { name: "Типы расходов", position: 6, type: "UserTaskDirectory", active: true },
        { name: "Национальные проекты", position: 7, type: "UserTaskDirectory", active: true },
        { name: "Государственные программы", position: 8, type: "UserTaskDirectory", active: true }
      ]

    end

  end
end
