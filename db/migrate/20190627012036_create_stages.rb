class CreateStages < ActiveRecord::Migration[5.2]
  def change
    create_table :stages do |t|
      t.integer :project_id
      t.date :start_date
      t.date :due_date
      t.string :done_ratio
      t.string :integer

      t.timestamps
    end
  end
end
