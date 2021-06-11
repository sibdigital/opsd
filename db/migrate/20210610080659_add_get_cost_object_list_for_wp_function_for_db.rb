class AddGetCostObjectListForWpFunctionForDb < ActiveRecord::Migration[5.2]
  def self.up
    execute <<-SQL
      create function get_cost_object_list_for_wp(id_work_package integer, id_project integer) returns SETOF cost_objects
          language plpgsql
      as
      $$
      DECLARE
                query_get_parent_cost_id text := 'WITH wp_hierarchy AS (
                                                        SELECT from_id AS wp_id, hierarchy
                                                        FROM relations
                                                        WHERE to_id = $1 and hierarchy <> 0
                                                    )
                                                    SELECT work_packages.cost_object_id
                                                    FROM wp_hierarchy
                                                             LEFT JOIN work_packages
                                                                       ON wp_hierarchy.wp_id = work_packages.id
                                                    WHERE NOT cost_object_id IS NULL
                                                    ORDER BY hierarchy
                                                    LIMIT 1;';
            
                parent_cost_object_id integer;   
                query_for_children_costs_by_parent_id text := 'WITH RECURSIVE r AS (
                                                                    SELECT $1 as id
                                                                
                                                                    UNION
                                                                
                                                                    SELECT cost_objects.id
                                                                    FROM cost_objects
                                                                             INNER JOIN r
                                                                                        ON cost_objects.parent_id = r.id
                                                                )
                                                                SELECT cost_objects.*
                                                                FROM cost_objects
                                                                         INNER JOIN r
                                                                                    ON cost_objects.id = r.id;';
                query_for_all_project_costs text := 'SELECT *
                                                     FROM cost_objects
                                                     WHERE cost_objects.project_id = $1;';
      
                query_for_all_free_project_costs text := 'WITH RECURSIVE all_costs as (
                                                          SELECT *
                                                          FROM cost_objects
                                                          WHERE project_id = $1
                                                      ),
                                                       parent_costs as (
                                                          SELECT *
                                                          FROM all_costs
                                                          WHERE all_costs.parent_id IS NULL
                                                      ),
                                                      not_available_parent_costs as (
                                                          SELECT parent_costs.*
                                                          FROM work_packages
                                                              INNER JOIN parent_costs
                                                                  ON work_packages.cost_object_id = parent_costs.id AND work_packages.id <> $2),
                                                      not_available_costs as (
                                                          SELECT not_available_parent_costs.*
                                                          FROM not_available_parent_costs
      
                                                          UNION
      
                                                          SELECT all_costs.*
                                                          FROM all_costs
                                                              INNER JOIN not_available_costs
                                                                  ON all_costs.parent_id = not_available_costs.id
                                                          )
                                                      SELECT all_costs.*
                                                      FROM all_costs
                                                      LEFT JOIN not_available_costs
                                                          ON all_costs.id = not_available_costs.id
                                                      WHERE not_available_costs.id IS NULL';
      BEGIN
          EXECUTE query_get_parent_cost_id INTO parent_cost_object_id USING id_work_package;
          IF parent_cost_object_id IS NULL THEN
              RETURN QUERY EXECUTE query_for_all_free_project_costs USING id_project, id_work_package;
          ELSE 
              RETURN QUERY EXECUTE query_for_children_costs_by_parent_id USING parent_cost_object_id;
          END IF;
      END
      $$;
    SQL
  end
end
