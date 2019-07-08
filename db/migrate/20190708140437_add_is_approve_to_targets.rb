class AddIsApproveToTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :is_approve, :boolean
  end
end
