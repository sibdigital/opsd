class AddPropsOrganizationsToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :organization_id, :bigint
  end
end
