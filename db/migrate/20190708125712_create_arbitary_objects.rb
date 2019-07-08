class CreateArbitaryObjects < ActiveRecord::Migration[5.2]
  def change
    create_table :arbitary_objects do |t|
      t.string :name
      t.integer :type_id
      t.integer :project_id
      t.boolean :is_approve

      t.timestamps
    end
  end
end
