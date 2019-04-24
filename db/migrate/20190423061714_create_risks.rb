class CreateRisks < ActiveRecord::Migration[5.2]
  def change
    create_table :risks do |t|
      t.integer :project_id
      t.string :name
      t.text :description
      t.integer :possibility
      t.integer :importance
      t.string :type
      t.integer :color_id
      t.integer :position

      t.timestamps
    end
  end
end
