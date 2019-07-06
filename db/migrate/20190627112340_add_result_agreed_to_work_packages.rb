class AddResultAgreedToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :result_agreed, :boolean
    add_column :work_package_journals, :result_agreed, :boolean
  end
end
