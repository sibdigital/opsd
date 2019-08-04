class PlanFactYearlyTargetValue < ActiveRecord::Base
  self.table_name = "v_plan_fact_yearly_target_values"
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :target
  belongs_to :project
end
