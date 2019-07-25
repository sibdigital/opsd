class CreateDiagramQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :diagram_queries do |t|
      t.string :name
      t.text :params

      t.timestamps
    end
  end
end
