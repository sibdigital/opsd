class AddSliceFunction < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION slice_last_quartered_plan_targets(slice_date TIMESTAMP WITHOUT TIME ZONE, projects integer[])
        RETURNS table(
                         national_project_id integer,
                         federal_project_id integer,
                         project_id integer,
                         target_id integer,
                         year integer,
                         quarter integer,
                         value numeric
                     ) AS
    $$
    BEGIN
        RETURN QUERY
            with prj_targ as ( select t.*
                               from targets as t
                                        inner join projects_array_to_table(projects) as p
                                                   using (project_id)
            ),
                 t_targets as( select pt.project_id, tev.*
                               from target_execution_values as tev
                                        inner join prj_targ as pt
                                                   on tev.target_id = pt.id
                               where max_date(tev.year, tev.quarter,null) <= first_quarter_day(slice_date :: DATE)
                 ),
    --              slice as (select t.project_id, t.target_id, t.year, min(min_year_quarter(t.year, t.quarter)) as quarter
                 slice as (select t.project_id, t.target_id, max(max_date(t.year,t.quarter,null)) as slice_date
                           from t_targets as t
                           group by t.project_id, t.target_id
                 ),
                 slice_values as (
    --                  select s.*, tev.value
                     select s.*, tev.year,min_year_quarter(tev.year,tev.quarter) as quarter, tev.value
                     from slice as s
                              inner join target_execution_values as tev
    --                                      on (s.target_id, min_year_quarter(s.year, s.quarter)) =
                                         on (s.target_id, s.slice_date) =
                                            (tev.target_id, max_date(tev.year, tev.quarter,null))
                 )
            select p.national_project_id, p.federal_project_id, s.project_id,
                   s.target_id, s.year, s.quarter, s.value
            from slice_values as s
                     left join (
                select p.national_project_id, p.federal_project_id, p.id as project_id
                from projects as p
                         inner join projects_array_to_table(projects) as prj
                                    on p.id = prj.project_id
            ) as p
                               using (project_id)
        ;
    END
    $$ LANGUAGE plpgsql
    ;

    -- select * from
    --   slice_last_quartered_plan_targets('2021-02-16' :: TIMESTAMP WITHOUT TIME ZONE, '{1,2,3,4}')
    -- ;
    SQL
  end
end
