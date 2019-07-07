#-- encoding: UTF-8
# This file written by BBM
# 24/06/2019

module BasicData
  class AttachTypeSeeder < Seeder
    def seed_data!
      AttachType.transaction do
        data.each do |attributes|
          AttachType.create!(attributes)
        end
      end
    end

    def applicable?
      AttachType.all.empty?
    end

    def not_applicable_message
      'Skipping attachment types as there are already some configured'
    end

    def data
      [
        #+-tan 2019.07.03 см прил 12 тт
        { name: "Отчет",     position: 1, is_default: true },
        { name: "Акт",    position: 2, is_default: false },
        { name: "Контракт",      position: 3, is_default: false },
        { name: "Протокол",      position: 4, is_default: false },
        { name: "Справка",      position: 5, is_default: false },
        { name: "НПА",      position: 6, is_default: false },
        { name: "Соглашение",      position: 7, is_default: false },
        { name: "Иной документ",      position: 8, is_default: false }
      ]
    end
  end
end
