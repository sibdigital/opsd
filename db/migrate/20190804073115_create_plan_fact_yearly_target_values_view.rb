class CreatePlanFactYearlyTargetValuesView < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      create or replace view v_plan_fact_yearly_target_values as (
        with slice as (select target_id, year, max(coalesce(quarter, 0)) as quarter
                       from target_execution_values as tev
                              inner join targets as t on tev.target_id = t.id
                       group by target_id, year
          ),
          slice_values as (
            select t.project_id, sv.*
            from (
                   select s.*, value
                   from slice as s
                          inner join target_execution_values as w
                                     on (s.target_id, s.year, s.quarter) =
                                        (w.target_id, w.year, coalesce(w.quarter, 0))
                 ) as sv
                   inner join targets as t on sv.target_id = t.id
            )
          select ROW_NUMBER () OVER (ORDER BY project_id, target_id, year) as id,
                 project_id,
                 target_id,
                 year,
                 quarter1_value,
                 quarter1_plan_value,
                 quarter2_value,
                 quarter2_plan_value,
                 quarter3_value,
                 quarter3_plan_value,
                 quarter4_value,
                 quarter4_plan_value,
                 coalesce(quarter4_value, quarter3_value, quarter2_value, quarter1_value) as final_fact_year_value,
                 sv.value                                                                 as target_plan_year_value
          from slice_values as sv
                 left join v_yeared_project_targets_fact_with_quarter_groups as vt using (project_id, target_id, year)
      )
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
