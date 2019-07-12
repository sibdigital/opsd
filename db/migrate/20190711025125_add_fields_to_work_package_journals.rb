class AddFieldsToWorkPackageJournals < ActiveRecord::Migration[5.2]
  def change
    add_column :work_package_journals, :organization_id, :bigint
    add_column :work_package_journals, :sed_href, :varchar
    add_column :work_package_journals, :target_id, :integer
    add_column :work_package_journals, :arbitary_object_id, :integer
  end
end
