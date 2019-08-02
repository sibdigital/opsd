class WorkPackageTarget < ActiveRecord::Base

  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

  belongs_to :target
  belongs_to :project
  belongs_to :work_package

  def <=>(work_package_target)
    name <=> Target.where(id: work_package_target.target_id).first.name
  end

  def to_s; name end
end
