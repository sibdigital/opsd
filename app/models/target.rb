class Target < ActiveRecord::Base
  belongs_to :project
  belongs_to :target_status, foreign_key: 'status_id'
  belongs_to :target_type, foreign_key: 'type_id'
  has_many :target_execution_values, dependent: :destroy
  #zbd(
  has_many :work_packages, foreign_key: 'target_id'
  #)
  #tan(
  has_many :work_package_targets, foreign_key: 'target_id'
  belongs_to :measure_unit, foreign_key: 'measure_unit_id'
  # )

  def option_name
    nil
  end

  def to_s
    name
  end
end
