## by zbd
# 22.06.2019
class Contract < ActiveRecord::Base
  has_many :work_packages, foreign_key: 'contract_id', dependent: :nullify

  acts_as_customizable

  validates :contract_num, presence: true, uniqueness: true
  belongs_to :project
  def option_name
    OptionName
  end

  def <=>(contract)
    name <=> contract.contract_subject
  end

  def to_s; name end

end
