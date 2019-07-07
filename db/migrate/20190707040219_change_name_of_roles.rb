class ChangeNameOfRoles < ActiveRecord::Migration[5.2]
  def change
    change_column :roles, :name, :varchar, :limit => 50
  end
end
