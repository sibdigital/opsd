#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module BasikData
  class TypedTargetSeeder < Seeder

    def initialize; end

    def seed_data!
      targets = translate_with_base_url("seeders.basic_data.typed_target")

      targets.each do |attributes|
        print '.'
        tr_attr = target_attributes(attributes)
        targ = Target.create tr_attr
      end

    end

    private

    def target_attributes(attributes)
      {
        name:         attributes[:name],
        type_id:      type_by_name(attributes[:type_id]),
        unit:         attributes[:unit],
        basic_value:  attributes[:basic_value],
        plan_value:   attributes[:plan_value],
        project_id:   project_by_name(attributes[:project]),
        parent_id: attributes[:parent_id],
        measure_unit_id: unit_by_name(attributes[:measure_unit_id]),
        is_approve: attributes[:is_approve],
        type: attributes[:type]
      }
    end

    def type_by_name(name)
      np = TargetType.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def unit_by_name(name)
      un = MeasureUnit.find_by(name: name)
      if un.present?
        un.id
      end
    end

    def target_values_attributes(attributes)
      {
        year:         attributes[:year],
        value:        attributes[:value],
        target_id:    target_by_name(attributes[:target])
      }
    end

    def project_by_name(name)
      np = Project.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def target_by_name(name)
      np = Target.find_by(name: name)
      if np != nil
        np.id
      end
    end
  end
end
