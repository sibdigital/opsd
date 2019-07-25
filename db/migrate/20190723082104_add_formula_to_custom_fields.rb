class AddFormulaToCustomFields < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :formula, :string
  end
end
