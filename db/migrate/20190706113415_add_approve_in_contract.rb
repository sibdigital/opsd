class AddApproveInContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :is_approve, :boolean
  end
end
