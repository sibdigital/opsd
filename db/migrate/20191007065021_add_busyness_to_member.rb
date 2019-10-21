class AddBusynessToMember < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :busyness, :decimal
  end
end
