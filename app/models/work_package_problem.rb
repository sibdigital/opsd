class WorkPackageProblem < ActiveRecord::Base

  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

  belongs_to :risk, class_name: 'ProjectRisk'
  belongs_to :project
  belongs_to :work_package

  belongs_to :user_creator, class_name: 'User'
  belongs_to :user_source, class_name: 'User'
  belongs_to :organization_source, class_name: 'Organization'

end
