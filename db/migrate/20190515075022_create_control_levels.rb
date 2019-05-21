class CreateControlLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :control_levels do |t|
      t.string :code
      t.string :name
      t.integer :color_id

      t.timestamps
    end
  end
end
