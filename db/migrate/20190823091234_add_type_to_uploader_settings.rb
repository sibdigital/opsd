class AddTypeToUploaderSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_uploader_settings, :column_type, :string
  end
end
