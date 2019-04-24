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
      ]

      # When selecting for an array of values, implicit order is applied
      # so we need to restore values by their name.
      colors_by_name = Color.where(name: color_names).index_by(&:name)
      colors = color_names.collect { |name| colors_by_name[name].id }

      [
        { name: I18n.t(:default_typed_risk_fire),    color_id: colors[0], position: 1 },
        { name: I18n.t(:default_typed_risk_flood),    color_id: colors[1], position: 2 },
      ]
    end
  end
end
