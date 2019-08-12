class AddRequiredControlDocToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :required_doc_type_id, :integer
  end
end
