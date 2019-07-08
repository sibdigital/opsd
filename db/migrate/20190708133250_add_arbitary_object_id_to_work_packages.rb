class AddArbitaryObjectIdToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :arbitary_object_id, :integer
  end
end
