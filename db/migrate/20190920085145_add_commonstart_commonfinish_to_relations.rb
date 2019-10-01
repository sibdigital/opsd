class AddCommonstartCommonfinishToRelations < ActiveRecord::Migration[5.2]
  def change
    add_column :relations, :commonstart, :integer, :default => 0, :null => false
    add_column :relations, :commonfinish, :integer, :default => 0, :null => false
    remove_index :relations,
                 name: 'index_relations_on_type_columns'
    add_index :relations,
              %i(from_id to_id hierarchy relates duplicates blocks follows commonstart commonfinish includes requires),
              name: 'index_relations_on_type_columns',
              unique: true
  end
end
