class CreateTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :targets do |t|
      t.integer :status
      t.string :name
      t.integer :typen
      t.string :unit
      t.decimal :basic_value
      t.decimal :plan_value
      t.string :comment
      t.string :project_id

      t.timestamps
    end
  end
end
