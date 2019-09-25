class CommunicationMeeting < ActiveRecord::Base

  belongs_to :user # заинтересованная сторона
  belongs_to :project

  has_many :communication_meeting_members, dependent: :destroy

end
