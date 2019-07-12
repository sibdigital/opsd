class AddTableNameToPlanUploaderSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_uploader_settings, :table_name, :string, null: false
  end
end
