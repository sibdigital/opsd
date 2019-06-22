class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.bigint :parent_id
      t.string :name
      t.string :inn
      t.boolean :is_legal_entity
      t.integer :org_type

      t.timestamps
    end
  end
end
