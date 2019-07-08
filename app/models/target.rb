class Target < ActiveRecord::Base
  belongs_to :project
  has_many :target_execution_values, dependent: :destroy
  #zbd(
  has_many :work_packages, foreign_key: 'target_id'
  #)
end
