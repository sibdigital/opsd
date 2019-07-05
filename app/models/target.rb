class Target < ApplicationRecord
  belongs_to :project
  has_many :target_execution_values, dependent: :destroy
end
