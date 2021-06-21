class AddMetaIdToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :meta_id, :bigint
  end
end
