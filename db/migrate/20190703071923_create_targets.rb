class CreateTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :targets do |t|
      t.integer :status_id
      t.string :name
      t.integer :type_id
      t.string :unit
      t.decimal :basic_value
      t.decimal :plan_value
      t.string :comment
      t.integer :project_id

      t.timestamps
    end
  end
end
