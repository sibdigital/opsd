#-- encoding: UTF-8
# This file written by BBM
# 23/04/2019

module BasicData
  class TypedRiskSeeder < Seeder
    def seed_data!
      TypedRisk.transaction do
        data.each do |attributes|
          TypedRisk.create!(attributes)
        end
      end
    end

    def applicable?
      TypedRisk.all.empty?
    end

    def not_applicable_message
      'Skipping typed risks as there are already some configured'
    end

    def data
      color_names = [
        'orange-0', # fire
        'blue-1', # flood
        'indigo-1', #
        'teal-3', #
        'red-6', #
        'yellow-2', #
        'lime-2', #
        'cyan-3', #
        'cyan-3', #
        'teal-6', #
        'teal-7', #
        'teal-9', #
        'red-9', #
        'gray-3', #
        'orange-3',
        'red-3', #
      ]

      # When selecting for an array of values, implicit order is applied
      # so we need to restore values by their name.
      colors_by_name = Color.where(name: color_names).index_by(&:name)
      colors = color_names.collect { |name| colors_by_name[name].id }

      [
        { name: "Не получено финасирование",    color_id: colors[0], position: 1 },
        { name: "Не заключен государственный контракт",    color_id: colors[1], position: 2 },
        { name: "Увеличен объем работ",    color_id: colors[2], position: 3 },
        { name: "Превышены сроки исполнения работ",    color_id: colors[3], position: 4 },
        { name: "Не выпущен необходимый нормативно-правовой акт",    color_id: colors[4], position: 5 },
        { name: "Не пройдены надзорные мероприятия",    color_id: colors[5], position: 6 },
        { name: "Изменено законодательство",    color_id: colors[6], position: 7 },
        { name: "Не найден подрядчик",    color_id: colors[7], position: 8 }
      ]
    end
  end
end
