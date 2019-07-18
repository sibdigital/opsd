class AddOwnerAndIsPossibilityToRisks < ActiveRecord::Migration[5.2]
  def change
    add_column :risks, :owner_id, :integer
    add_column :risks, :is_possibility, :boolean
  end
end
