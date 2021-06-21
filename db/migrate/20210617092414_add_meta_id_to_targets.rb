class AddMetaIdToTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :meta_id, :bigint
  end
end
