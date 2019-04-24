#-- encoding: UTF-8
# This file written by BBM
# 23/04/2019

class TypedRisk < Risk
  belongs_to :color

  #OptionName и соотв функция непонятно для чего служат
  OptionName = :risks_typed_risks

  def option_name
    OptionName
  end

  def color_label
    I18n.t('typed_risks.edit.typed_risk_color_text')
  end
end
