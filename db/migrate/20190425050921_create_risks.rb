class CreateRisks < ActiveRecord::Migration[5.2]
  def change
    create_table :risks do |t|
      t.integer :project_id
      t.string :name
      t.text :description
      t.integer :possibility_id
      t.integer :importance_id
      t.string :type
      t.integer :color_id

      t.timestamps
    end
  end
end
