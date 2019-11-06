class AddColumnsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :national_project_target, :text
    add_column :projects, :government_program, :text
    add_column :projects, :mission_of_head, :text
    add_column :project_journals, :national_project_target, :text
    add_column :project_journals, :government_program, :text
    add_column :project_journals, :mission_of_head, :text
  end
end
