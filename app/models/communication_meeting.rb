class CommunicationMeeting < ActiveRecord::Base

  belongs_to :user # заинтересованная сторона
  belongs_to :project

end
