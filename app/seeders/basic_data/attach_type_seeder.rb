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
        { name: "Word",     position: 1, is_default: true },
        { name: "Excel",    position: 2, is_default: false },
        { name: "Pdf",      position: 3, is_default: false }
      ]
    end
  end
end
