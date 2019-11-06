class GeneralMeeting < Meeting
  self.table_name = 'meetings'
  default_scope { where(is_general: true) }
  scope :from_tomorrow, -> { where(['start_time >= ?', Date.tomorrow.beginning_of_day]) }
  scope :with_users_by_date, -> {
    order("#{Meeting.table_name}.title ASC")
      .includes({ participants: :user }, :author)
  }
end
