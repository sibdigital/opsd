class RemoveTargetIdFromWorkPackages < ActiveRecord::Migration[5.2]
  def change
    remove_column :work_packages, :target_id, :integer
  end
end
