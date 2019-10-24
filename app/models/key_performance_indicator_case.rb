class KeyPerformanceIndicatorCase < ActiveRecord::Base

  belongs_to :key_performance_indicator, foreign_key: 'key_performance_indicator_id'
  belongs_to :role, foreign_key: 'role_id'

  def to_s; key_performance_indicator.name + ' ' + id.to_s end

  def period_humanized
    case period
    when 'Daily'
      "ежедневно"
    when 'Weekly'
      "еженедельно"
    when 'Monthly'
      "ежемесячно"
    when 'Quarterly'
      "ежеквартально"
    when 'Yearly'
      "ежегодно"
    else
      period
    end
  end
end
