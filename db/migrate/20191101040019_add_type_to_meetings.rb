class AddTypeToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :is_general, :boolean, default: false
  end
end
