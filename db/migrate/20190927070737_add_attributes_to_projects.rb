class AddAttributesToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :fact_start_date, :date
    add_column :projects, :fact_due_date, :date
    add_column :projects, :invest_amount, :decimal
    add_column :projects, :is_program, :boolean
    add_column :projects, :address_id, :integer
  end
end
