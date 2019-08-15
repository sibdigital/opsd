class AddJournalableWpForPlanFact < ActiveRecord::Migration[5.2]
  def change
    add_column :work_package_journals, :raion_id, :bigint
    add_column :work_package_journals, :work_package_id, :bigint
    add_column :work_package_journals, :updated_at, :timestamp
    add_column :work_package_journals, :fact_due_date, :timestamp
    add_column :work_packages, :fact_due_date, :timestamp
  end
end
