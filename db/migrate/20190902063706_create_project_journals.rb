class CreateProjectJournals < ActiveRecord::Migration[5.2]
  def change
    create_table :project_journals do |t|
      t.integer :journal_id, null: false
      t.string :name, default: '', null: false
      t.text :description
      t.boolean :is_public, default: true, null: false
      t.integer :parent_id
      t.datetime :created_on
      t.datetime :updated_on
      t.string :identifier
      t.integer :status, default: 1, null: false
      t.integer :lft
      t.integer :rgt
      t.belongs_to :project_type, type: :int
      t.belongs_to :responsible, type: :int
      t.belongs_to :work_packages_responsible, type: :int

      t.integer :project_approve_status_id
      t.integer :project_status_id
      t.datetime :start_date
      t.datetime :due_date
      t.integer :national_project_id
      t.integer :federal_project_id

      t.index [:journal_id]
    end
  end
end
