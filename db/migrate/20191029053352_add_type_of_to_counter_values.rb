class AddTypeOfToCounterValues < ActiveRecord::Migration[5.2]
  def change
    add_column :counter_values, :type_of, :string
  end
end
