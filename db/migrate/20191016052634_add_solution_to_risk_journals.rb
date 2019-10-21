class AddSolutionToRiskJournals < ActiveRecord::Migration[5.2]
  def change
    add_column :risk_journals, :solution, :text
    add_column :risk_journals, :project_section_id, :integer
  end
end
