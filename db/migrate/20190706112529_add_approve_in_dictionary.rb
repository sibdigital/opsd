class AddApproveInDictionary < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :is_approve, :boolean
    add_column :positions, :is_approve, :boolean
    add_column :risks, :is_approve, :boolean
  end
end
