class AddMetaIdToCostObjects < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_objects, :meta_id, :bigint
  end
end
