class AddPropsOrganizationsToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :org_controlling_id, :bigint
    add_column :work_packages, :org_performer_id, :bigint
  end
end
