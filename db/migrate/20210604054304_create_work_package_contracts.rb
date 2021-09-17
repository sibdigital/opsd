class CreateWorkPackageContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :work_package_contracts do |t|
      t.integer :work_package_id
      t.integer :contract_id
      t.string :comment
      t.integer :author_id
      t.timestamps
    end
  end
end
