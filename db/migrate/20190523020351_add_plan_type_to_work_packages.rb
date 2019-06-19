class AddPlanTypeToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :plan_type, :string
  end
end
