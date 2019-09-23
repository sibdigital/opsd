class AddCommonstartCommonfinishToRelations < ActiveRecord::Migration[5.2]
  def change
    add_column :relations, :commonstart, :integer, :default => 0, :null => false
    add_column :relations, :commonfinish, :integer, :default => 0, :null => false
  end
end
