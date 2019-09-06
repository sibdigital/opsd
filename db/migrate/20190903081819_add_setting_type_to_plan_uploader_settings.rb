class AddSettingTypeToPlanUploaderSettings < ActiveRecord::Migration[5.2]
  # чтобы можно было задавать несколько настроек для одной таблицы
  def change
    add_column :plan_uploader_settings, :setting_type, :string
  end
end
