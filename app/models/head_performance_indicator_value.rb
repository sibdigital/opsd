class HeadPerformanceIndicatorValue < ActiveRecord::Base
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице
  has_many :head_performance_indicator_values, foreign_key: 'head_performance_indicator_id'
end
