class KeyPerformanceIndicator < ActiveRecord::Base
  #OptionName = :kpi_option

  #def option_name
    #OptionName
  #end

  def to_s; name end
end
