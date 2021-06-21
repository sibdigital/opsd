class AddMetaIdToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :meta_id, :bigint
  end
end
