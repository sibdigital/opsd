class NationalProject < ActiveRecord::Base
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице
  acts_as_journalized
  has_many :projects, foreign_key: "national_project_id"
  has_many :projects_federal, foreign_key: "federal_project_id", class_name: "Project"
  has_many :agreements, foreign_key: 'national_project_id'
  # bbm( исправил следующую строку т.к. по-моему она не должна была работать
  has_many :agreements_federal, foreign_key: 'federal_project_id'
  # )

  has_many :national_work_package_quarterly_targets, -> { where(type: 'National') }, foreign_key: 'national_project_id', class_name: "WorkPackageQuarterlyTarget"
  has_many :national_plan_fact_yearly_target_values, -> { where(type: 'National') }, foreign_key: 'national_project_id', class_name: "PlanFactYearlyTargetValue"
  has_many :national_plan_quarterly_target_values, -> { where(type: 'National') }, foreign_key: 'national_project_id', class_name: "PlanQuarterlyTargetValue"
  has_many :national_plan_fact_quarterly_target_values, -> { where(type: 'National') }, foreign_key: 'national_project_id', class_name: "PlanFactQuarterlyTargetValue"

  has_many :federal_work_package_quarterly_targets, -> { where(type: 'Federal') }, foreign_key: 'federal_project_id', class_name: "WorkPackageQuarterlyTarget"
  has_many :federal_plan_fact_yearly_target_values, -> { where(type: 'Federal') }, foreign_key: 'federal_project_id', class_name: "PlanFactYearlyTargetValue"
  has_many :federal_plan_quarterly_target_values, -> { where(type: 'Federal') }, foreign_key: 'federal_project_id', class_name: "PlanQuarterlyTargetValue"
  has_many :federal_plan_fact_quarterly_target_values, -> { where(type: 'Federal') }, foreign_key: 'federal_project_id', class_name: "PlanFactQuarterlyTargetValue"

  def to_s
    name
  end
end
