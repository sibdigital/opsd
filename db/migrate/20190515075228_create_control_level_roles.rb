class CreateControlLevelRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :control_level_roles do |t|
      t.integer :control_level_id
      t.integer :role_id

      t.timestamps
    end
  end
end
