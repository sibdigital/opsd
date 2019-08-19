class RiskProblemStat < ActiveRecord::Base

  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

  self.table_name = "v_risk_problem_stat"
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :work_package
  belongs_to :project
  belongs_to :work_package_problem, foreign_key: "id"
  belongs_to :importance, foreign_key: "importance_id", class_name: 'Importance'
end
