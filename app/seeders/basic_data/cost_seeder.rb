#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module BasicData
  class CostSeeder < Seeder

    def initialize; end

    def seed_data!
      cost_types = translate_with_base_url("seeders.demo_data.cost_types")

      cost_types.each do |attributes|
        print '.'
        tr_attr = cost_type_attributes(attributes)
        targ = CostType.create tr_attr
        targ.save!
      end

    end

    private

    def cost_type_attributes(attributes)
      {
        name:         attributes[:name],
        unit:         attributes[:unit],
        unit_plural:  attributes[:unit_plural]
      }
    end

  end
end
