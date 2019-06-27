class AddVersionToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :version, :integer
  end
end
