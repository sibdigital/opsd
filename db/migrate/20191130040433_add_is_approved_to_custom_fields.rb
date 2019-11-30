class AddIsApprovedToCustomFields < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :is_approved, :boolean, default: true
  end
end
