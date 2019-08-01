class MeetingProtocol < ActiveRecord::Base
  belongs_to :meeting_content, foreign_key: 'meeting_contents_id'

  belongs_to :user, class_name: 'User', foreign_key: 'assigned_to_id'
end

