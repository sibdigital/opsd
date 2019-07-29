class ChangeWorkPackageRisks < ActiveRecord::Migration[5.2]
  def change
    change_column :work_package_problems, :user_source_id, :integer, {null: true}
    change_column :work_package_problems, :organization_source_id, :integer, {null: true}
    change_column :work_package_problems, :risk_id, :integer, {null: true}
  end
end
