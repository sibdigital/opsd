#-- encoding: UTF-8
# This file written by BBM
# 25/04/2019

class Importance < Enumeration
  has_many :risks, foreign_key: 'importance_id'

  OptionName = :enumeration_risk_importance

  def option_name
    OptionName
  end

  def objects_count
    risks.count
  end

  def transfer_relations(to)
    risks.update_all(importance_id: to.id)
  end
end
