class AddViewedAtToMessageParticipiants < ActiveRecord::Migration[5.2]
  def change
    add_column :message_participants, :viewed_at, :datetime
  end
end
