class KeyPerformanceIndicatorCase < ActiveRecord::Base

  belongs_to :key_performance_indicator, foreign_key: 'key_performance_indicator_id'
  belongs_to :role, foreign_key: 'role_id'
end
