class CreatePlanUploaderSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_uploader_settings do |t|
      t.string :column_name, null: false
      t.integer :column_num, null: false
      t.boolean :is_pk, null: true

      t.timestamps
    end
  end
end
