class AddColumnsToContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :auction_date, :date
    add_column :contracts, :schedule_date, :date
  end
end
