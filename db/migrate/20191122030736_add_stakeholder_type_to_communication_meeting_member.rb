class AddStakeholderTypeToCommunicationMeetingMember < ActiveRecord::Migration[5.2]
  def change
    add_column :communication_meeting_members, :stakeholder_type, :string
    add_column :communication_requirements, :stakeholder_type, :string
  end
end
