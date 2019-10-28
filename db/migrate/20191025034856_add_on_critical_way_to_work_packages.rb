class AddOnCriticalWayToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :on_critical_way, :boolean
  end
end
