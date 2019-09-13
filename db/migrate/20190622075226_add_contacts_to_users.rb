class AddContactsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone_wrk, :string#, limit: 14
    add_column :users, :phone_wrk_add, :string#, limit: 6
    add_column :users, :phone_mobile, :string#, limit: 12
    add_column :users, :mail_add, :string#, limit: 60
    add_column :users, :address, :string#, limit: 160
    add_column :users, :cabinet, :string#, limit: 6
  end
end
