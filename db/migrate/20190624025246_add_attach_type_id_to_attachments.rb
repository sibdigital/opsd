class AddAttachTypeIdToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :attach_type_id, :integer
  end
end
