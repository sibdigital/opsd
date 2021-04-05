class AlterWorkPackagesColumnPlanType < ActiveRecord::Migration[5.2]
  def change
    change_column_default :work_packages, :plan_type, 'execution'
  end
end
