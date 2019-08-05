class AddUserPosition < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :position_id, :integer
  end
end
