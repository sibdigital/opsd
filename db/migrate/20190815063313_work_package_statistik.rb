class WorkPackageStatistik < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      create or replace view v_work_package_stat as (
        select w.*, coalesce(rp.count, 0) as created_problem_count,
               coalesce(rps.count, 0) as solved_problem_count,
               coalesce(att.count, 0) as attach_count
        from work_packages as w
               left join (select work_package_id, count(status) as count
                          from work_package_problems
                          where status = 'created'
                          group by work_package_id
        ) as rp
                         on (w.id) = (rp.work_package_id)
               left join (select work_package_id, count(status) as count
                          from work_package_problems
                          where status = 'solved'
                          group by work_package_id
        ) as rps
                         on (w.id) = (rps.work_package_id)
               left join (select container_id as work_package_id, count(filename) as count
                          from attachments
                          where container_type = 'WorkPackage'
                          group by work_package_id
      
        ) as att
                          on (w.id) = (att.work_package_id)
      )
    SQL

    execute <<-SQL
     create or replace view v_work_package_ispoln_stat as (
        select
               p.national_project_id,
               p.federal_project_id,
               wpp.*,
               NOT (wpp.ispolneno OR wpp.ne_ispolneno OR wpp.est_riski) as v_rabote,
               wpp.due_date::date - current_date::date                     as days_to_due,
               wpp.ispolneno and wpp.due_date >= wpp.fact_due_date         as ispolneno_v_srok
        from (
               select wpsi.*,
                      case
                        when wpsi.ispolneno = false and due_date < current_date and
                             not lower(status_name) in (lower('Завершен'), lower('Отменен')) then true
                        else false end as ne_ispolneno,
                      case
                        when wpsi.ispolneno = false and (due_date >= current_date or due_date is null) and created_problem_count > 0 and
                             not lower(status_name) in (lower('Завершен'), lower('Отменен')) then true
                        else false end as est_riski
               from (
                      select wps.*,
                             s.name as status_name,
                             --case
                             --  when wps.result_agreed AND created_problem_count = 0 AND attach_count > 0 and
                             --       lower(s.name) = lower('Завершен') and not due_date is null then true
                             --  else false
                             --  end  as ispolneno
                             not fact_due_date is null as ispolneno
                      from v_work_package_stat as wps
                             left join statuses as s
                                       on wps.status_id = s.id
                    ) as wpsi
             ) as wpp
            left join projects as p
            on wpp.project_id = p.id
      )
    SQL

    execute <<-SQL
      create or replace view v_project_ispoln_stat as (
        select
               ROW_NUMBER () OVER (ORDER BY national_project_id, federal_project_id, project_id, type_id) as id,
               national_project_id,
               federal_project_id,
               project_id,
               type_id,
               count(id)                                            as all_work_packages,
               sum(case when ispolneno = true then 1 else 0 end)    as ispolneno,
               sum(case when ne_ispolneno = true then 1 else 0 end) as ne_ispolneno,
               sum(case when est_riski = true then 1 else 0 end)    as est_riski,
               sum(case when v_rabote = true then 1 else 0 end)     as v_rabote
        from v_work_package_ispoln_stat as wis
        group by national_project_id, federal_project_id, project_id, type_id
      )
    SQL

  end
end
