class AddTargetIdToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :target_id, :integer
    #add_column :work_packages_journals, :target_id, :integer
  end
end
