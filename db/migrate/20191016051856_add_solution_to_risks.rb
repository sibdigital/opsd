class AddSolutionToRisks < ActiveRecord::Migration[5.2]
  def change
    add_column :risks, :solution, :text
    add_column :risks, :project_section_id, :integer
  end
end
