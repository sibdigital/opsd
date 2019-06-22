class AddPatronymicToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :patronymic, :string, limit: 30
  end
end
