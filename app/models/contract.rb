## by zbd
# 22.06.2019
class Contract < ActiveRecord::Base

  validates :contract_num, presence: true, uniqueness: true

  def option_name
    OptionName
  end

  def <=>(contract)
    name <=> contract.contract_subject
  end

  def to_s; name end
end
