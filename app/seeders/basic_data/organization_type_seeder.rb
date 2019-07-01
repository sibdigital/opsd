#-- encoding: UTF-8
# This file written by XCC
# 22/06/2019

module BasicData
  class OrganizationTypeSeeder < Seeder
    def seed_data!
      OrganizationType.transaction do
        data.each do |attributes|
          OrganizationType.create!(attributes)
        end
      end
    end

    def applicable?
      OrganizationType.all.empty?
    end

    def not_applicable_message
      'Skipping organization types as there are already some configured'
    end

    def data

      [
        { name: "Контрагент", position: 1, type: "OrganizationType", active: true },
        { name: "Орган исполнительной власти", position: 2, type: "OrganizationType", active: true },
        { name: "Муниципальное образование", position: 3, type: "OrganizationType", active: true },
      ]

    end

  end
end
