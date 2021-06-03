class CreateWorkPackageLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :work_package_links do |t|
      t.integer :work_package_id
      t.string :link
      t.string :name
      t.integer :author_id
      t.timestamps
    end
  end
end
