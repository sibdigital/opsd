class Target < ActiveRecord::Base
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

  TYPED_TARGET  = 'TypedTarget'
  #bbm(
  has_many :cost_objects
  # )
  belongs_to :project
  belongs_to :resultassigned, class_name: 'User', foreign_key: 'result_assigned'
  belongs_to :target_status, foreign_key: 'status_id'
  belongs_to :target_type, foreign_key: 'type_id'
  has_many :target_execution_values, dependent: :destroy
  #zbd(
  #has_many :work_packages, foreign_key: 'target_id'
  #)
  #tan(
  has_many :work_package_targets, foreign_key: 'target_id'
  belongs_to :measure_unit, foreign_key: 'measure_unit_id'
  has_many :work_package_quarterly_targets, foreign_key: 'target_id'
  has_many :plan_fact_yearly_target_values, foreign_key: 'target_id'
  has_many :plan_quarterly_target_values, foreign_key: 'target_id'
  has_many :plan_fact_quarterly_target_values, foreign_key: 'target_id'
  # )

  #acts_as_list scope: 'type = \'#{type}\''

  def option_name
    nil
  end

  def to_s
    name
  end
end
