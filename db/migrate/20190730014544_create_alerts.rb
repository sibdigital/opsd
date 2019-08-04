class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.integer :entity_id
      t.date :alert_date
      t.string :entity_type
      t.string :alert_type

      t.timestamps
    end
  end
end
