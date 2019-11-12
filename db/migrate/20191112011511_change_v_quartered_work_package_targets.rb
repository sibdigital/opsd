class ChangeVQuarteredWorkPackageTargets < ActiveRecord::Migration[5.2]
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
    SQL
  end
end
