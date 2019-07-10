class AddIdParentToTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :parent_id, :integer
  end
end
