#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module DemoData
  class TargetSeeder < Seeder

    def initialize; end

    def seed_data!
      targets = translate_with_base_url("seeders.demo_data.project_targets")
      targets_values = translate_with_base_url("seeders.demo_data.target_execution_values")
      work_package_targets = translate_with_base_url("seeders.demo_data.work_package_targets")

      targets.each do |attributes|
        print '.'
        tr_attr = target_attributes(attributes)
        targ = Target.create tr_attr
      end

      targets_values.each do |attributes|
        print '.'
        tr_attr = target_values_attributes(attributes)
        targ = TargetExecutionValue.create tr_attr
      end

      work_package_targets.each do |attributes|
         print '.'
         tr_attr = work_package_targets_attributes(attributes)
         targ = WorkPackageTarget.create tr_attr
         #print tr_attr.name
      end

    end

    private

    def target_attributes(attributes)
      {
        name:         attributes[:name],
        typen:        type_by_name(attributes[:typen]),
        unit:         attributes[:unit],
        basic_value:  attributes[:basic_value],
        plan_value:   attributes[:plan_value],
        project_id:   project_by_name(attributes[:project])
      }
    end

    def type_by_name(name)
      np = TargetType.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def target_values_attributes(attributes)
      {
        year:         attributes[:year],
        value:        attributes[:value],
        target_id:    target_by_name(attributes[:target])
      }
    end

    def work_package_targets_attributes(attributes)
      {
        year:         attributes[:year],
        quarter:         attributes[:quarter],
        month:         attributes[:month],
        value:        attributes[:value],
        target_id:    target_by_name(attributes[:target]),
        project_id:  project_by_name(attributes[:project]),
        work_package_id: work_package_by_subject(attributes[:work_package_subject])
      }
    end

    def work_package_by_subject(subject)
      np = WorkPackage.find_by(subject: subject)
      if np != nil
        np.id
      end
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
