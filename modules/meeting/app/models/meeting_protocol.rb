class MeetingProtocol < ActiveRecord::Base
  belongs_to :meeting_content, foreign_key: 'meeting_contents_id'
end

