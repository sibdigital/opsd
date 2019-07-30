class CreateMeetingProtocols < ActiveRecord::Migration[5.2]
  def change
    create_table :meeting_protocols do |t|
      t.integer :meeting_contents_id
      t.integer :assigned_to_id
      t.string :text
      t.date :due_date

      t.timestamps
    end
  end
end
