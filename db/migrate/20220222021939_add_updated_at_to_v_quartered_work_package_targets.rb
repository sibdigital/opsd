class AddUpdatedAtToVQuarteredWorkPackageTargets < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      create or replace view v_quartered_work_package_targets
            (project_id, target_id, work_package_id, year, quarter, month, value, plan_value, updated_at) as
      WITH slice AS (
          SELECT wpt.project_id,
                 wpt.target_id,
                 wpt.work_package_id,
                 wpt.year,
                 wpt.quarter,
                 max(COALESCE(wpt.month, 0)) AS month
          FROM work_package_targets wpt
                   JOIN work_packages wp ON wpt.work_package_id = wp.id
          GROUP BY wpt.project_id, wpt.target_id, wpt.work_package_id, wpt.year, wpt.quarter
      ),
           slice_values AS (
               SELECT s.project_id,
                      s.target_id,
                      s.work_package_id,
                      s.year,
                      s.quarter,
                      s.month,
                      w.value,
                      w.plan_value,
                      w.updated_at
               FROM slice s
                        JOIN work_package_targets w ON s.project_id = w.project_id AND s.target_id = w.target_id AND
                                                       s.work_package_id = w.work_package_id AND s.year = w.year AND
                                                       s.quarter = w.quarter AND COALESCE(s.month, 0) = COALESCE(w.month, 0)
           )
      SELECT slice_values.project_id,
             slice_values.target_id,
             slice_values.work_package_id,
             slice_values.year,
             slice_values.quarter,
             slice_values.month,
             slice_values.value,
             slice_values.plan_value,
             slice_values.updated_at
      FROM slice_values;
    SQL
  end
end
