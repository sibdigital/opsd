class AddBasePlanDateInWorkPackage < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :first_due_date, :timestamp
    add_column :work_packages, :last_due_date, :timestamp
    add_column :work_packages, :first_start_date, :timestamp
    add_column :work_packages, :last_start_date, :timestamp

    add_column :work_package_journals, :first_due_date, :date
    add_column :work_package_journals, :last_due_date, :date
    add_column :work_package_journals, :first_start_date, :date
    add_column :work_package_journals, :last_start_date, :date
  end
end
