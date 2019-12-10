class AddUpdatedAtToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :updated_on, :datetime
    add_column :document_journals, :updated_on, :datetime
    add_index :documents, :updated_on
  end
end
