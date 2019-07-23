#-- encoding: UTF-8
# This file written by BBM
# 25/04/2019

class TypedRisk < Risk
  OptionName = :risk_typed_risks

  acts_as_customizable

  def option_name
    OptionName
  end

  def color_label
    I18n.t('typed_risks.edit.typed_risk_color_text')
  end
end
