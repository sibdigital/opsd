class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.string :contract_subject, limit: 100
      t.date :contract_date
      t.decimal :price, precision: 15, scale: 2
      t.string :executor, limit: 100

      t.timestamps
    end
  end
end
