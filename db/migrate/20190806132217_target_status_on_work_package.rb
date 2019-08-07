class TargetStatusOnWorkPackage < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      create or replace view v_target_status_on_work_package as (
          with targ as (
            select t.id as target_id, t.project_id, wpt.work_package_id, year
            from targets as t
                   left join (select wpt.project_id, wpt.work_package_id, wpt.target_id, year
                              from work_package_targets as wpt
                              group by wpt.project_id, wpt.work_package_id, wpt.target_id, year) as wpt on t.id = wpt.target_id
            )
          select targ.target_id, targ.year, wpi.*
          from targ
                   left join v_work_package_ispoln_stat as wpi on targ.work_package_id = wpi.id
      )
    SQL
  end
end
