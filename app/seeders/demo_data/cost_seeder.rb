#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module DemoData
  class CostSeeder < Seeder

    def initialize; end

    def seed_data!
      cost_types = translate_with_base_url("seeders.demo_data.cost_types")
      cost_objects = translate_with_base_url("seeders.demo_data.cost_objects")
      material_budget_items = translate_with_base_url("seeders.demo_data.material_budget_items")
      cost_entries = translate_with_base_url("seeders.demo_data.cost_entries")
      rates = translate_with_base_url("seeders.demo_data.rates")

      cost_types.each do |attributes|
        print '.'
        tr_attr = cost_type_attributes(attributes)
        targ = CostType.create tr_attr
        targ.save!
      end

      rates.each do |attributes|
        print '.'
        tr_attr = rate_attributes(attributes)
        targ = Rate.create tr_attr
        targ.save!
      end

      cost_objects.each do |attributes|
        print '.'
        tr_attr = cost_objects_attributes(attributes)
        targ = CostObject.create tr_attr
        targ.save!
      end

      material_budget_items.each do |attributes|
         print '.'
         tr_attr = material_budget_item_attributes(attributes)
         targ = MaterialBudgetItem.create tr_attr
         targ.save!
         #print tr_attr.name
      end

      cost_entries.each do |attributes|
        print '.'
        tr_attr = cost_entry_attributes(attributes)
        targ = CostEntry.create tr_attr
        targ.save!

        wp = work_package_by_subject(attributes[:work_package_subject])
        if wp.cost_object_id == nil
          cost_object_id = cost_object_by_subject(attributes[:cost_object_subject])
          wp.cost_object_id = cost_object_id
          wp.save!
        end
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

    def rate_attributes(attributes)
      {
        rate:         attributes[:rate],
        type:         attributes[:type],
        cost_type_id:  cost_type_name(attributes[:cost_type_name]),
        valid_from: Date.today.beginning_of_year
      }
    end

    def cost_objects_attributes(attributes)
      {
        project_id:         project_by_name(attributes[:project]),
        subject:         attributes[:subject],
        type:  attributes[:type],
        fixed_date: Date.today.beginning_of_month,
        description: ''
      }
    end

    def material_budget_item_attributes(attributes)
      {
        cost_object_id:      cost_object_by_subject(attributes[:cost_object_subject]),
        cost_type_id:        cost_type_name(attributes[:cost_type_name]),
        units:    attributes[:units]
      }
    end

    def cost_entry_attributes(attributes)
      wp = work_package_by_subject(attributes[:work_package_subject])
      {
        project_id:  project_by_name(attributes[:project]),
        work_package_id: wp.id,
        user_id: wp.assigned_to_id,
        spent_on: Date.today.beginning_of_month,
        cost_type_id:         cost_type_name(attributes[:cost_type_name]),
        costs:        attributes[:costs],
        units:        attributes[:costs],
        comments: ''
      }
    end

    def work_package_by_subject(subject)
      WorkPackage.find_by(subject: subject)
    end

    def project_by_name(name)
      np = Project.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def cost_object_by_subject(subject)
      puts subject
      np = CostObject.find_by(subject: subject)
      if np != nil
        np.id
      end
    end

    def cost_type_name(name)
      np = CostType.find_by(name: name)
      if np != nil
        np.id
      end
    end

  end
end
