class AddDirectManager < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :direct_manager_id, :integer
  end
end
