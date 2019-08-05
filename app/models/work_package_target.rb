class WorkPackageTarget < ActiveRecord::Base

  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

  belongs_to :target
  belongs_to :project
  belongs_to :work_package
  belongs_to :national_project, -> { where(type: 'National') }, class_name: "NationalProject", foreign_key: "national_project_id"
  belongs_to :federal_project, -> { where(type: 'Federal') }, class_name: "NationalProject", foreign_key: "federal_project_id"

  def <=>(work_package_target)
    name <=> Target.where(id: work_package_target.target_id).first.name
  end

  def to_s; name end
end
