class AddPlanValueToWorkPackageTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :work_package_targets, :plan_value, :decimal
  end
end
