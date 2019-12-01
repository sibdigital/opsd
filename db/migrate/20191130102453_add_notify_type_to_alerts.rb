class AddNotifyTypeToAlerts < ActiveRecord::Migration[5.2]
  def change
    add_column :alerts, :notify_type, :integer, default: 0
  end
end
