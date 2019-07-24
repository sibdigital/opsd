class CreateAgreements < ActiveRecord::Migration[5.2]
  def change
    create_table :agreements do |t|
      t.date    :date_agreement
      t.string  :number_agreement
      t.integer :count_days
      t.integer :project_id
      t.integer :national_project_id
      t.integer :federal_project_id
      t.string  :state_program
      t.string  :other_liabilities_2141
      t.string  :other_liabilities_2142
      t.string  :other_liabilities_2281
      t.string  :other_liabilities_2282
      t.date    :date_end

      t.timestamps
    end
  end
end
