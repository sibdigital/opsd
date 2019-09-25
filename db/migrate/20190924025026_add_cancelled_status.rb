class AddCancelledStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :is_cancelled, :boolean
  end
end
