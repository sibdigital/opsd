require 'digest/sha1'

class ProductionCalendar < ActiveRecord::Base
  self.table_name = 'production_calendars'
  validates_presence_of :type, :date, :is_first, :hours

  def option_name
    OptionName
  end

end
