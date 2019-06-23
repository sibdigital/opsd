## by zbd
# 22.06.2019
class Contract < ActiveRecord::Base

  validates :contract_num, presence: true, uniqueness: true

  def option_name
    OptionName
  end
end
