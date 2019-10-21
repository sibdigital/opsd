class AddTypeToBoards < ActiveRecord::Migration[5.2]
  def change
    add_column :boards, :is_default, :boolean
    add_column :board_journals, :is_default, :boolean
  end
end
