class KeyPerformanceIndicator < ActiveRecord::Base
  #OptionName = :kpi_option

  #def option_name
    #OptionName
  #end
  #
  belongs_to :kpi_calc_method, foreign_key: 'method_id', class_name: "KpiCalcMethod"
  belongs_to :kpi_object, foreign_key: 'object_id', class_name: "KpiObject"

  def to_s;
    name
  end
end
