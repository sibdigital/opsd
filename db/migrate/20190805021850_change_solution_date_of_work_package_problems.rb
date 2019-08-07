class ChangeSolutionDateOfWorkPackageProblems < ActiveRecord::Migration[5.2]
  def change
    remove_column :work_package_problems, :solution_date
    add_column :work_package_problems, :solution_date, :date
  end
end
