class CreatePlanFactQuarterlyTargetValuesView < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      create or replace view v_plan_quarterly_target_values as (
        with targ as (select tev.target_id, tev.year, tev.quarter, tev.value
                      from target_execution_values as tev
          ),
          targyear as (
            select t.id as target_id, t.project_id, targ.year
            from targets as t
                   left join targ on t.id = targ.target_id
            ),
          quart as (
            select t.target_id, t.project_id, t.year, quarter1_value, quarter2_value, quarter3_value, quarter4_value
            from targyear as t
                   left join (select tev.target_id, tev.year, tev.quarter, tev.value as quarter1_value
                              from targ as tev
                              where tev.quarter = 1) as q1
                             using (target_id, year)
                   left join (select tev.target_id, tev.year, tev.quarter, tev.value as quarter2_value
                              from targ as tev
                              where tev.quarter = 2) as q2
                             using (target_id, year)
                   left join (select tev.target_id, tev.year, tev.quarter, tev.value as quarter3_value
                              from targ as tev
                              where tev.quarter = 3) as q3
                             using (target_id, year)
                   left join (select tev.target_id, tev.year, tev.quarter, tev.value as quarter4_value
                              from targ as tev
                              where tev.quarter = 4) as q4
                             using (target_id, year)
            )
          select ROW_NUMBER () OVER (ORDER BY national_project_id, federal_project_id, project_id, target_id, year) as id,
                 national_project_id, federal_project_id, q.*, coalesce(quarter4_value, quarter3_value, quarter2_value, quarter1_value, t.value) as year_value
          from quart as q
                 left join targ as t using (target_id, year)
                 left join projects as p
                           on q.project_id = p.id
          )
          ;
          drop view if exists v_plan_fact_quarterly_target_values
          ;
          create or replace view v_plan_fact_quarterly_target_values as (
            select ROW_NUMBER () OVER (ORDER BY tt.national_project_id, tt.federal_project_id, project_id, target_id, year) as id,
                   tt.national_project_id,
                   tt.federal_project_id,
                   tt.project_id,
                   tt.target_id,
                   tt.year,
                   tt.quarter4_value      as target_quarter4_value,
                   tt.quarter3_value      as target_quarter3_value,
                   tt.quarter2_value      as target_quarter2_value,
                   tt.quarter1_value      as target_quarter1_value,
                   tt.year_value          as target_year_value,
                   wt.quarter1_value      as fact_quarter1_value,
                   wt.quarter2_value      as fact_quarter2_value,
                   wt.quarter3_value      as fact_quarter3_value,
                   wt.quarter4_value      as fact_quarter4_value,
                   coalesce(wt.quarter4_value , wt.quarter3_value , wt.quarter2_value , wt.quarter1_value, 0) 
                      as fact_year_value,
                   wt.quarter1_plan_value as plan_quarter1_value,
                   wt.quarter2_plan_value as plan_quarter2_value,
                   wt.quarter3_plan_value as plan_quarter3_value,
                   wt.quarter4_plan_value as plan_quarter4_value,
                   coalesce(wt.quarter4_plan_value , wt.quarter3_plan_value , wt.quarter2_plan_value , wt.quarter1_plan_value, 0) 
                      as plan_year_value
            from v_plan_quarterly_target_values as tt
                   left join v_yeared_project_targets_fact_with_quarter_groups as wt
                             using (project_id, target_id, year)
          )
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
