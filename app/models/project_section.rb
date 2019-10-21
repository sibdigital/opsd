#-- encoding: UTF-8
# This file written by BBM
# 16/10/2019

class ProjectSection < Enumeration
  has_many :risks, foreign_key: 'project_section_id'

  OptionName = :enumeration_risk_project_section_id

  def option_name
    OptionName
  end

  def objects_count
    risks.count
  end

  def transfer_relations(to)
    risks.update_all(project_section_id: to.id)
  end
end
