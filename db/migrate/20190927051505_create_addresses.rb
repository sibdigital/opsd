class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :address
      t.integer :raion_id
      t.integer :project_id
    end
  end
end
