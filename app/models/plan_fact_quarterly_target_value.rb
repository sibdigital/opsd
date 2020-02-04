class PlanFactQuarterlyTargetValue < ActiveRecord::Base
  self.table_name = "v_plan_fact_quarterly_target_values"
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :target
  belongs_to :project
  belongs_to :national_project, -> { where(type: 'National') }, class_name: "NationalProject", foreign_key: "national_project_id"
  belongs_to :federal_project, -> { where(type: 'Federal') }, class_name: "NationalProject", foreign_key: "federal_project_id"

  def self.slice(project_id)
    result = ActiveRecord::Base.connection.exec_query("with quarter_slice as (with slice as (
    select national_project_id,
           federal_project_id,
           project_id,
           target_id,
           year,
           fact_quarter1_value,
           fact_quarter2_value,
           fact_quarter3_value,
           fact_quarter4_value,
           target_quarter1_value,
           target_quarter2_value,
           target_quarter3_value,
           target_quarter4_value,
           plan_quarter1_value,
           plan_quarter2_value,
           plan_quarter3_value,
           plan_quarter4_value
    from v_plan_fact_quarterly_target_values as v
    where project_id in (#{project_id})
    group by national_project_id,
             federal_project_id,
             project_id,
             target_id, year,
             fact_quarter1_value,
             fact_quarter2_value,
             fact_quarter3_value,
             fact_quarter4_value,
             target_quarter1_value,
             target_quarter2_value,
             target_quarter3_value,
             target_quarter4_value,
             plan_quarter1_value,
             plan_quarter2_value,
             plan_quarter3_value,
             plan_quarter4_value
)
SELECT fact_quarter1_value as value_fact, target_quarter1_value as value_target, plan_quarter1_value as value_plan, 1 as quarter, year, target_id
from slice
union
select fact_quarter2_value, target_quarter2_value, plan_quarter2_value, 2 as quarter, year, target_id
from slice
union
select fact_quarter3_value, target_quarter3_value, plan_quarter3_value, 3 as quarter, year, target_id
from slice
union
select fact_quarter4_value, target_quarter4_value, plan_quarter4_value, 4 as quarter, year, target_id
from slice
order by year, quarter) SELECT row_number() OVER() as id, * from quarter_slice where (value_fact NOTNULL or value_target NOTNULL or value_plan NOTNULL);")
  end
end
