class RiskStatistik < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      create or replace view v_risk_problem_stat as (
        with problems as (
          select wpp.id,
                 wpp.work_package_id,
                 case
                   when status = 'created' and not risk_id is null then risk_id
                   when status = 'solved' and not risk_id is null then risk_id
                   when status = 'created' and risk_id is null then id
                   when status = 'created' and risk_id is null then id end               as problem_id,
                 case
                   when status = 'created' and not risk_id is null then 'created_risk'
                   when status = 'solved' and not risk_id is null then 'solved_risk'
                   when status = 'created' and risk_id is null then 'created_problem'
                   when status = 'created' and risk_id is null then 'solved_problem' end as type
          from work_package_problems as wpp
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
      )
    SQL

    execute <<-SQL
      create or replace view v_project_risk_on_work_packages_stat as (
        select ROW_NUMBER() OVER (ORDER BY national_project_id, federal_project_id, project_id, type, importance_id) as id,
               pj.national_project_id,
               pj.federal_project_id,
               project_id,
               type,
               importance_id,
               count(coalesce(problem_id, 0))                                                                        as count
        from (
               select w.project_id,
                      w.id,
                      rps.problem_id,
                      coalesce(rps.type, 'no_risk_problem') as type,
                      rps.importance_id,
                      rps.importance
               from work_packages as w
                      left join v_risk_problem_stat as rps on w.id = rps.work_package_id
             ) as p
               left join projects as pj on p.project_id = pj.id
        group by pj.national_project_id, pj.federal_project_id, project_id, type, importance_id
      )
    SQL
  end
end
