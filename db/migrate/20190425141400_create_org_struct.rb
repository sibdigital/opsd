#+-tan 2019.04.25
class CreateOrgStruct < ActiveRecord::Migration[5.2]
  def change
    create_position
    create_organization
    create_depart
    add_users_columns
  end

  private

  def create_position
    create_table :positions do |t|
      t.string :name

      t.timestamps
    end
  end

  def create_organization
    create_table :organizations do |t|
      t.string :name

      t.timestamps
    end
  end

  def create_depart
    create_table :departs do |t|
      t.integer :organization_id
      t.string :name

      t.timestamps
    end
  end

  def add_users_columns
    #add_column(table_name, column_name, type, options = {}) public
    add_column :users, :patronymic, :text
    add_column :users, :position_id, :integer
    add_column :users, :depart_id, :integer
  end
end
