class CreateTargetExecutionValues < ActiveRecord::Migration[5.2]
  def change
    create_table :target_execution_values do |t|
      t.integer :target_id
      t.integer :year
      t.integer :quarter
      t.decimal :value

      t.timestamps
    end
  end
end
