class ChangeViewsVPlanQuarterlyTargetValuesAndVRiskProblemStat < ActiveRecord::Migration[5.2]
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
            select distinct t.target_id, t.project_id, t.year, quarter1_value, quarter2_value, quarter3_value, quarter4_value
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
                 national_project_id, federal_project_id, q.*, coalesce(quarter4_value, quarter3_value, quarter2_value, quarter1_value) as year_value
          from quart as q
                 left join projects as p
                           on q.project_id = p.id
          )
      ;

            create or replace view v_risk_problem_stat as (
        with problems as (
          select wpp.id,
                 wpp.project_id,
                 wpp.work_package_id,
                 case
                   when status = 'created' and not (wpp.risk_id IS NULL or wpp.risk_id = 0) then risk_id
                   when status = 'solved' and not (wpp.risk_id IS NULL or wpp.risk_id = 0) then risk_id
                   when status = 'created' and (wpp.risk_id IS NULL or wpp.risk_id = 0) then id
                   when status = 'solved' and (wpp.risk_id IS NULL or wpp.risk_id = 0) then id end               as problem_id,
                 case
                   when status = 'created' and not (wpp.risk_id IS NULL or wpp.risk_id = 0) then 'created_risk'
                   when status = 'solved' and not (wpp.risk_id IS NULL or wpp.risk_id = 0) then 'solved_risk'
                   when status = 'created' and (wpp.risk_id IS NULL or wpp.risk_id = 0) then 'created_problem'
                   when status = 'solved' and (wpp.risk_id IS NULL or wpp.risk_id = 0) then 'solved_problem' end as type
          from work_package_problems as wpp
            inner join (
              select w.id as work_package_id
              from work_packages as w
              inner join (
                  select id
                  from statuses as s
                  where s.is_closed = false
                ) as s
              on w.status_id = s.id
            ) as not_closed
            using (work_package_id)
          ),
          risk_imp as (
            select pr.*, r.importance_id, imp.name as importance
            from (select *
                  from problems as p
                  where type in ('created_risk', 'solved_risk')
                 ) as pr
                   left join risks as r
                             on pr.problem_id = r.id
                   left join (select * from enumerations as e where type = 'Importance') as imp
                             on r.importance_id = imp.id
            )
          select prb.*, r.importance_id, r.importance
          from problems as prb
                 left join risk_imp as r using (id, problem_id, type)
      );
    SQL
  end
end
