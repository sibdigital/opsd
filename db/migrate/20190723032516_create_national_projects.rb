class CreateNationalProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :national_projects do |t|
      t.string :name
      t.string :leader
      t.string :position_of_leader
      t.integer :type
      t.integer :parent_id
    end
  end
end
