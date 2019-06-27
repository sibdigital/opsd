class AddContractIdToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :contract_id, :integer
    add_column :work_packages_journals, :contract_id, :integer
  end
end
