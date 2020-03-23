# require 'digest/sha1'
class ProductionCalendar < ActiveRecord::Base
  @@transfered = nil
  # self.table_name = 'production_calendars'
  validates_presence_of :day_type, :date, :year
  # has_many :production_calendars
  after_save :reset_transfered

  def reset_transfered
    @@transfered = nil
  end

  def self.get_transfered
    if @@transfered.nil?
      @@transfered = self.all
    end
    @@transfered
  end
  def option_name
    OptionName
  end

end
