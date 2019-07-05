class AddWorkPackageIdToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :work_package_id, :integer
  end
end
