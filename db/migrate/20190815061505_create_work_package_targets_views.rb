class CreateWorkPackageTargetsViews < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      --целевые показатели кварталам, берется срез последних в каждом квартале
      create or replace view v_quartered_work_package_targets as (
        with slice as (select project_id, target_id, work_package_id, year, quarter, max(coalesce(month, 0)) as month
                       from work_package_targets as wpt
                       group by project_id, target_id, work_package_id, year, quarter
          ),
          slice_values as (
            select s.*, value, plan_value
            from slice as s
                   inner join work_package_targets as w
                              on (s.project_id, s.target_id, s.work_package_id, s.year, s.quarter, coalesce(s.month, 0)) =
                                 (w.project_id, w.target_id, w.work_package_id, w.year, w.quarter, coalesce(w.month, 0))
            )
          select project_id, target_id, work_package_id, year, quarter, month, value, plan_value
          from slice_values
      )
;
-- срез целевых показателей с планом и фактом разнесенным по кварталам
create or replace view v_quartered_work_package_targets_with_quarter_groups as (
  select ROW_NUMBER () OVER (ORDER BY national_project_id, federal_project_id, project_id, target_id, work_package_id, year) as id,
         p.national_project_id as national_project_id,
         p.federal_project_id as federal_project_id,
         project_id,
         target_id,
         work_package_id,
         year,
         max(quarter1_value)      as quarter1_value,
         max(quarter1_plan_value) as quarter1_plan_value,
         max(quarter2_value)      as quarter2_value,
         max(quarter2_plan_value) as quarter2_plan_value,
         max(quarter3_value)      as quarter3_value,
         max(quarter3_plan_value) as quarter3_plan_value,
         max(quarter4_value)      as quarter4_value,
         max(quarter4_plan_value) as quarter4_plan_value
  from (
         select project_id,
                target_id,
                work_package_id,
                year,
                value      as quarter1_value,
                plan_value as quarter1_plan_value,
                0          as quarter2_value,
                0          as quarter2_plan_value,
                0          as quarter3_value,
                0          as quarter3_plan_value,
                0          as quarter4_value,
                0          as quarter4_plan_value
         from v_quartered_work_package_targets
         where false
         union all
         select project_id,
                target_id,
                work_package_id,
                year,
                value      as quarter1_value,
                plan_value as quarter1_plan_value,
                null       as quarter2_value,
                null       as quarter2_plan_value,
                null       as quarter3_value,
                null       as quarter3_plan_value,
                null       as quarter4_value,
                null       as quarter4_plan_value
         from v_quartered_work_package_targets
         where quarter = 1
         union all
         select project_id,
                target_id,
                work_package_id,
                year,
                null       as quarter1_value,
                null       as quarter1_plan_value,
                value      as quarter2_value,
                plan_value as quarter2_plan_value,
                null       as quarter3_value,
                null       as quarter3_plan_value,
                null       as quarter4_value,
                null       as quarter4_plan_value
         from v_quartered_work_package_targets
         where quarter = 2
         union all
         select project_id,
                target_id,
                work_package_id,
                year,
                null       as quarter1_value,
                null       as quarter1_plan_value,
                null       as quarter2_value,
                null       as quarter2_plan_value,
                value      as quarter3_value,
                plan_value as quarter3_plan_value,
                null       as quarter4_value,
                null       as quarter4_plan_value
         from v_quartered_work_package_targets
         where quarter = 3
         union all
         select project_id,
                target_id,
                work_package_id,
                year,
                null       as quarter1_value,
                null       as quarter1_plan_value,
                null       as quarter2_value,
                null       as quarter2_plan_value,
                null       as quarter3_value,
                null       as quarter3_plan_value,
                value      as quarter4_value,
                plan_value as quarter4_plan_value
         from v_quartered_work_package_targets
         where quarter = 4
       ) as s
         left join projects as p
                   on s.project_id = p.id
  group by p.national_project_id, p.federal_project_id, project_id, target_id, work_package_id, year
)
;
-- срез целевых показателей сгруппированный по году с планом и фактом
create or replace view v_yeared_project_targets_fact_with_quarter_groups as (
       select ROW_NUMBER() OVER (ORDER BY p.national_project_id, p.federal_project_id, project_id, target_id, year) as id,
              p.national_project_id                                                                             as national_project_id,
              p.federal_project_id                                                                              as federal_project_id,
              project_id,
              target_id,
              year,
              sum(quarter1_value)                                                                               as quarter1_value,
              sum(quarter1_plan_value)                                                                          as quarter1_plan_value,
              sum(quarter2_value)                                                                               as quarter2_value,
              sum(quarter2_plan_value)                                                                          as quarter2_plan_value,
              sum(quarter3_value)                                                                               as quarter3_value,
              sum(quarter3_plan_value)                                                                          as quarter3_plan_value,
              sum(quarter4_value)                                                                               as quarter4_value,
              sum(quarter4_plan_value)                                                                          as quarter4_plan_value
       from v_quartered_work_package_targets_with_quarter_groups as vt
                   left join projects as p
                             on vt.project_id = p.id
       group by p.national_project_id,
                p.federal_project_id,
                project_id,
                target_id,
                year
      );
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
