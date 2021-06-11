class AddCostObjectIdToCostEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_entries, :cost_object_id, :integer
  end
end
