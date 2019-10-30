class AddFieldsToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :some_href, :string
    add_column :attachments, :locked, :boolean
    add_column :attachments, :user_locked_id, :integer
  end
end
