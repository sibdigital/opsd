class WorkPackageTarget < ActiveRecord::Base

  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

  belongs_to :target
  belongs_to :project
  belongs_to :work_package

end
