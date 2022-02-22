class ChangeVYearedProjectTargetsFactWithQuarterGroups < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      create or replace view v_yeared_project_targets_fact_with_quarter_groups
                  (id, national_project_id, federal_project_id, project_id, target_id, work_package_id, year, quarter1_value,
                   quarter1_plan_value, quarter2_value, quarter2_plan_value, quarter3_value, quarter3_plan_value,
                   quarter4_value, quarter4_plan_value, updated_at)
      as
      WITH slice AS (
          SELECT v.national_project_id,
                 v.federal_project_id,
                 v.project_id,
                 v.target_id,
                 v.year,
                 max(v.updated_at) AS updated_at
          FROM v_quartered_work_package_targets_with_quarter_groups v
          GROUP BY v.national_project_id, v.federal_project_id, v.project_id, v.target_id, v.year
      )
      SELECT d.id,
             d.national_project_id,
             d.federal_project_id,
             d.project_id,
             d.target_id,
             d.work_package_id,
             d.year,
             d.quarter1_value,
             d.quarter1_plan_value,
             d.quarter2_value,
             d.quarter2_plan_value,
             d.quarter3_value,
             d.quarter3_plan_value,
             d.quarter4_value,
             d.quarter4_plan_value,
             d.updated_at
      FROM v_quartered_work_package_targets_with_quarter_groups d
               JOIN slice USING (national_project_id, federal_project_id, project_id, target_id, year, updated_at);
    SQL
  end
end
