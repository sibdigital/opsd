class CreatePlanUploader < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_uploaders do |t|
      t.integer :status
      t.string :name
      t.datetime :upload_at
    end
  end
end
