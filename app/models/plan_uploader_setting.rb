#copyright by zbd
#    11.07.2019

class PlanUploaderSetting < ActiveRecord::Base
  validates :table_name, presence: true
  validates :column_name, presence: true, uniqueness: {case_sensitive: false}
  validates :column_num, presence: true, uniqueness: true

end
