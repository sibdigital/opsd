class CreateCriticalWays < ActiveRecord::Migration[5.2]
  def change
    create_table :critical_ways do |t|
      t.integer :wp_id
      t.boolean :on_crit_way

      t.timestamps
    end
  end
end
