class AddParentIdToCostObjects < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_objects, :parent_id, :integer
  end
end
