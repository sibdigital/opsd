class AddDataForPopUpToAlerts < ActiveRecord::Migration[5.2]
  def change
    add_column :alerts, :created_by, :integer
    add_column :alerts, :to_user, :integer
    add_column :alerts, :readed, :boolean, default: false
    add_column :alerts, :about, :string
  end
end
