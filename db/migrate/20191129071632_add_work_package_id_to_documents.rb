class AddWorkPackageIdToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :work_package_id, :integer
  end
end
