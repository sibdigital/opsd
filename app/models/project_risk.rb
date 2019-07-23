#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

class ProjectRisk < Risk
  belongs_to :project
  OptionName = :risk_project_risks

  acts_as_customizable

  def option_name
    OptionName
  end

  def color_label
    I18n.t('project_risks.edit.project_risk_color_text')
  end
end
