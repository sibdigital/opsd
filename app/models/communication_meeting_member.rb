class CommunicationMeetingMember < ActiveRecord::Base

  belongs_to :stakeholder # заинтересованная сторона
  belongs_to :project
  belongs_to :communication_meeting #


end
