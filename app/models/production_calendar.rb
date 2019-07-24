# require 'digest/sha1'

class ProductionCalendar < ActiveRecord::Base
  # self.table_name = 'production_calendars'
  validates_presence_of :type_of_day, :date, :year
  # has_many :production_calendars

  def option_name
    OptionName
  end

end
