#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module DemoData
  class TypedRiskSeeder < Seeder

    def initialize; end

    def seed_data!
      typed_risks_data = translate_with_base_url("seeders.demo_data.typed_risks")

      typed_risks_data.each do |attributes|
        print '.'

        tr_attr = base_typed_risk_attributes attributes

        typed_risk = TypedRisk.create tr_attr
      end
    end

    private

    def base_typed_risk_attributes(attributes)
      {
        name:         attributes[:name],
        description:  attributes[:description],
        possibility:  find_possibility(attributes),
        importance:   find_importance(attributes),
        color:     color_by_name(attributes[:color_id]),
        is_approve:   attributes[:is_approve]
      }
    end

    def find_possibility(attributes)
      Possibility.find_by(name: translate_with_base_url(attributes[:possibility]))
    end

    def find_importance(attributes)
      Importance.find_by(name: translate_with_base_url(attributes[:importance]))
    end

    def color_by_name(color_name)
      Color.find_by(name: color_name)
    end
  end
end
