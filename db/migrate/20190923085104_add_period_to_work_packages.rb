class AddPeriodToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :period_id, :integer
  end
end
