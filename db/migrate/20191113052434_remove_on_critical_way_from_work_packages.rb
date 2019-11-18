class RemoveOnCriticalWayFromWorkPackages < ActiveRecord::Migration[5.2]
  def change
    remove_column :work_packages, :on_critical_way
  end
end
