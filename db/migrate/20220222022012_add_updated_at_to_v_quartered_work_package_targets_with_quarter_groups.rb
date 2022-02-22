class AddUpdatedAtToVQuarteredWorkPackageTargetsWithQuarterGroups < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      create or replace view v_quartered_work_package_targets_with_quarter_groups
                  (id, national_project_id, federal_project_id, project_id, target_id, work_package_id, year, quarter1_value,
                   quarter1_plan_value, quarter2_value, quarter2_plan_value, quarter3_value, quarter3_plan_value,
                   quarter4_value, quarter4_plan_value, updated_at)
      as
      SELECT row_number()
             OVER (ORDER BY p.national_project_id, p.federal_project_id, s.project_id, s.target_id, s.work_package_id, s.year) AS id,
             p.national_project_id,
             p.federal_project_id,
             s.project_id,
             s.target_id,
             s.work_package_id,
             s.year,
             max(s.quarter1_value)                                                                                             AS quarter1_value,
             max(s.quarter1_plan_value)                                                                                        AS quarter1_plan_value,
             max(s.quarter2_value)                                                                                             AS quarter2_value,
             max(s.quarter2_plan_value)                                                                                        AS quarter2_plan_value,
             max(s.quarter3_value)                                                                                             AS quarter3_value,
             max(s.quarter3_plan_value)                                                                                        AS quarter3_plan_value,
             max(s.quarter4_value)                                                                                             AS quarter4_value,
             max(s.quarter4_plan_value)                                                                                        AS quarter4_plan_value,
             s.updated_at
      FROM (SELECT v_quartered_work_package_targets.project_id,
                   v_quartered_work_package_targets.target_id,
                   v_quartered_work_package_targets.work_package_id,
                   v_quartered_work_package_targets.year,
                   v_quartered_work_package_targets.value      AS quarter1_value,
                   v_quartered_work_package_targets.plan_value AS quarter1_plan_value,
                   0                                           AS quarter2_value,
                   0                                           AS quarter2_plan_value,
                   0                                           AS quarter3_value,
                   0                                           AS quarter3_plan_value,
                   0                                           AS quarter4_value,
                   0                                           AS quarter4_plan_value,
                   v_quartered_work_package_targets.updated_at
            FROM v_quartered_work_package_targets
            WHERE false
            UNION ALL
            SELECT v_quartered_work_package_targets.project_id,
                   v_quartered_work_package_targets.target_id,
                   v_quartered_work_package_targets.work_package_id,
                   v_quartered_work_package_targets.year,
                   v_quartered_work_package_targets.value      AS quarter1_value,
                   v_quartered_work_package_targets.plan_value AS quarter1_plan_value,
                   NULL::integer                               AS quarter2_value,
                   NULL::integer                               AS quarter2_plan_value,
                   NULL::integer                               AS quarter3_value,
                   NULL::integer                               AS quarter3_plan_value,
                   NULL::integer                               AS quarter4_value,
                   NULL::integer                               AS quarter4_plan_value,
                   v_quartered_work_package_targets.updated_at
            FROM v_quartered_work_package_targets
            WHERE v_quartered_work_package_targets.quarter = 1
            UNION ALL
            SELECT v_quartered_work_package_targets.project_id,
                   v_quartered_work_package_targets.target_id,
                   v_quartered_work_package_targets.work_package_id,
                   v_quartered_work_package_targets.year,
                   NULL::numeric                               AS quarter1_value,
                   NULL::numeric                               AS quarter1_plan_value,
                   v_quartered_work_package_targets.value      AS quarter2_value,
                   v_quartered_work_package_targets.plan_value AS quarter2_plan_value,
                   NULL::integer                               AS quarter3_value,
                   NULL::integer                               AS quarter3_plan_value,
                   NULL::integer                               AS quarter4_value,
                   NULL::integer                               AS quarter4_plan_value,
                   v_quartered_work_package_targets.updated_at
            FROM v_quartered_work_package_targets
            WHERE v_quartered_work_package_targets.quarter = 2
            UNION ALL
            SELECT v_quartered_work_package_targets.project_id,
                   v_quartered_work_package_targets.target_id,
                   v_quartered_work_package_targets.work_package_id,
                   v_quartered_work_package_targets.year,
                   NULL::numeric                               AS quarter1_value,
                   NULL::numeric                               AS quarter1_plan_value,
                   NULL::numeric                               AS quarter2_value,
                   NULL::numeric                               AS quarter2_plan_value,
                   v_quartered_work_package_targets.value      AS quarter3_value,
                   v_quartered_work_package_targets.plan_value AS quarter3_plan_value,
                   NULL::integer                               AS quarter4_value,
                   NULL::integer                               AS quarter4_plan_value,
                   v_quartered_work_package_targets.updated_at
            FROM v_quartered_work_package_targets
            WHERE v_quartered_work_package_targets.quarter = 3
            UNION ALL
            SELECT v_quartered_work_package_targets.project_id,
                   v_quartered_work_package_targets.target_id,
                   v_quartered_work_package_targets.work_package_id,
                   v_quartered_work_package_targets.year,
                   NULL::numeric                               AS quarter1_value,
                   NULL::numeric                               AS quarter1_plan_value,
                   NULL::numeric                               AS quarter2_value,
                   NULL::numeric                               AS quarter2_plan_value,
                   NULL::numeric                               AS quarter3_value,
                   NULL::numeric                               AS quarter3_plan_value,
                   v_quartered_work_package_targets.value      AS quarter4_value,
                   v_quartered_work_package_targets.plan_value AS quarter4_plan_value,
                   v_quartered_work_package_targets.updated_at
            FROM v_quartered_work_package_targets
            WHERE v_quartered_work_package_targets.quarter = 4) s
               LEFT JOIN projects p ON s.project_id = p.id
      GROUP BY p.national_project_id, p.federal_project_id, s.project_id, s.target_id, s.work_package_id, s.year,
               s.updated_at;
    SQL
  end
end
