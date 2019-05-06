class CreateRiskCharacts < ActiveRecord::Migration[5.2]
  def change
    create_table :risk_characts do |t|
      t.integer :risk_id
      t.string :name
      t.text :description
      t.string :type
      t.integer :position

      t.timestamps
    end
  end
end
