#-- encoding: UTF-8
#+-xcc 2019.06.23
class MeasureUnit < ActiveRecord::Base

    has_many :targets, foreign_key: 'measure_unit_id', dependent: :nullify
    has_many :head_performance_indicators, foreign_key: 'measure_unit_id', dependent: :nullify

    def to_s
      name
    end

end
