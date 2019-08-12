class AddCompletedAtToMeetingProtocol < ActiveRecord::Migration[5.2]
  def change
    add_column :meeting_protocols, :completed_at, :date
  end
end
