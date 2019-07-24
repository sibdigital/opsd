class CreateProductionCalendars < ActiveRecord::Migration[5.2]
  def change
    create_table :production_calendars do |t|
      t.integer :day_type
      t.date :date
      t.integer :year
    end
  end
end
