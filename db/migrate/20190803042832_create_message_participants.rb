class CreateMessageParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :message_participants do |t|
      t.integer :message_id
      t.integer :user_id

      t.timestamps
    end
  end
end
