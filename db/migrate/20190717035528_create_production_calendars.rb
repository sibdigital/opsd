class CreateProductionCalendars < ActiveRecord::Migration[5.2]
  def change
    create_table :production_calendars do |t|
      t.integer :type
      t.date :date
      t.boolean :is_first
      t.integer :hours
    end
  end
end
