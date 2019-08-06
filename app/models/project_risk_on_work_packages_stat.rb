class ProjectRiskOnWorkPackagesStat < ActiveRecord::Base

  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

  self.table_name = "v_project_risk_on_work_packages_stat"
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :project
  belongs_to :national_project, -> { where(type: 'National') }, class_name: "NationalProject", foreign_key: "national_project_id"
  belongs_to :federal_project, -> { where(type: 'Federal') }, class_name: "NationalProject", foreign_key: "federal_project_id"
  belongs_to :importance, foreign_key: "importance_id", class_name: 'Importance'
end
