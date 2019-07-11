#copyright by zbd
#    11.07.2019

class PlanUploaderSetting < ActiveRecord::Base
  #validates_uniqueness_of :column_num
  #validates_uniqueness_of :column_name, case_sensitive: false
  validates :contract_num, presence: true, uniqueness: {case_sensitive: false}
  validates :column_num, presence: true, uniqueness: true

end
