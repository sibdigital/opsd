class AddPlanNumPpToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :plan_num_pp, :string, limit: 10
    add_column :work_package_journals, :plan_num_pp, :string, limit: 10
  end
end
