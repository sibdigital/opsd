class AddTypeToTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :type, :string
  end
end
