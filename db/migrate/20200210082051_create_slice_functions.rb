class CreateSliceFunctions < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
          CREATE OR REPLACE FUNCTION projects_array_to_table(projects integer[])
              RETURNS table(
                  project_id integer
                           ) AS
          $$
          BEGIN
              RETURN QUERY
                  SELECT cast(s.unnest as  integer) as project_id
                  from(
                          SELECT unnest FROM unnest( projects )
                      ) as s
              ;
          END
          $$ LANGUAGE plpgsql
          ;
          -- example:
          -- select * from
          -- projects_array_to_table('{1,2,3,4}')

          CREATE OR REPLACE FUNCTION last_month_day(date)
              RETURNS date AS
          $$
          SELECT (date_trunc('MONTH', $1) + INTERVAL '1 MONTH - 1 day')::date;
          $$ LANGUAGE 'sql'
              IMMUTABLE STRICT
          ;

          -- example: select last_month_day('2020-02-16 20:38:40')

          CREATE OR REPLACE FUNCTION last_quarter_day(date)
              RETURNS date AS
          $$
          SELECT (date_trunc('QUARTER', $1) + INTERVAL '3 MONTH - 1 day')::date;
          $$ LANGUAGE 'sql'
              IMMUTABLE STRICT
          ;

          -- example: select last_quarter_day('2020-02-16 20:38:40')

          CREATE OR REPLACE FUNCTION max_year_quarter(pyear integer, pquarter integer)
              RETURNS integer AS
          $$
          declare
              ryear int := 0;
              rquarter int := 0 ;
          BEGIN
              ryear := pyear;
              if pquarter = 0 OR pquarter is null OR pquarter > 4 then
                  rquarter := 4;
              else
                  rquarter := pquarter;
              end if;
              return rquarter;
          END
          $$ LANGUAGE plpgsql
          ;
          --select max_year_quarter(2020, 1)

          CREATE OR REPLACE FUNCTION max_quarter_month(pyear integer, pquarter integer, pmonth integer)
              RETURNS integer AS
          $$
          declare
              ryear int := 0;
              rquarter int := 0 ;
              rmonth int := 0;
          BEGIN
              ryear := pyear;
              rquarter:= max_year_quarter(ryear, pquarter);
              if pmonth = 0 OR pmonth is null OR pmonth > 12 then
                  if rquarter = 1 then
                      rmonth := 3;
                  elseif rquarter = 2 then
                      rmonth := 6;
                  elseif rquarter = 3 then
                      rmonth := 9;
                  else
                      rmonth := 12;
                  end if;
              else
                  rmonth := pmonth;
              end if;
              return rmonth;
          END
          $$ LANGUAGE plpgsql
          ;
          --select max_quarter_month(2020, 2, null)

          CREATE OR REPLACE FUNCTION max_date(pyear integer, pquarter integer, pmonth integer)
              RETURNS date AS
          $$
          declare
              ryear int := 0;
              rquarter int := 0 ;
              rmonth int := 0;
              rcurdate date;
              rdate date;
          BEGIN
              ryear := pyear;
              rquarter:= max_year_quarter(ryear, pquarter);
              rmonth := max_quarter_month(ryear, rquarter, pmonth);

              rcurdate := make_date(ryear, rmonth, 1);
              rdate := last_month_day(rcurdate);
              return rdate;
          END
          $$ LANGUAGE plpgsql
          ;
          --example: select max_date(2020, 1, 2), max_date(2019, 4, 12), max_date(2019, 4, null), max_date(2020, null, null), max_date(2020, 1, 0);

          --целевые показатели кварталам, берется срез последних в каждом квартале
          CREATE OR REPLACE FUNCTION slice_last_quartered_fact_targets(slice_date TIMESTAMP WITHOUT TIME ZONE, projects integer[])
              RETURNS table(
                               national_project_id integer,
                               federal_project_id integer,
                               project_id integer,
                               target_id integer,
                               work_package_id integer,
                               year integer,
                               quarter integer,
                               month integer,
                               value numeric,
                               plan_value numeric
                           ) AS
          $$
          BEGIN
              RETURN QUERY
                  with wp_targets as( select wpt.*
                                      from work_package_targets as wpt
                                               inner join projects_array_to_table(projects) as prj
                                                          using (project_id)
                                               inner join (select id as work_package_id from work_packages
                                                                                                 inner join projects_array_to_table(projects) as prj
                                                                                                            using (project_id)
                                      ) as wp
                                                          using (work_package_id)
                                      where max_date(wpt.year, wpt.quarter, wpt.month) <= last_month_day(slice_date :: DATE)
                  ),
          --              slice as (select wpt.project_id, wpt.target_id, wpt.work_package_id, wpt.year, wpt.quarter, max(max_quarter_month(wpt.year, wpt.quarter, wpt.month)) as month
                       slice as (select wpt.project_id, wpt.target_id, wpt.work_package_id, max(max_date(wpt.year,wpt.quarter,wpt.month)) as slice_date
                                 from wp_targets as wpt
                                 group by wpt.project_id, wpt.target_id, wpt.work_package_id
                       ),
                       slice_values as (
          --                  select s.*, w.value, w.plan_value
                           select s.*, w.year, w.quarter, w.month, w.value, w.plan_value
                           from slice as s
                                    inner join work_package_targets as w
                                               on (s.project_id, s.target_id, s.work_package_id,s.slice_date) =
          --                                         (w.project_id, w.target_id, w.work_package_id, w.year, w.quarter, max_quarter_month(w.year, w.quarter, w.month))
                                                  (w.project_id, w.target_id, w.work_package_id, max_date(w.year, w.quarter, w.month))
                       )
                  select p.national_project_id, p.federal_project_id, s.project_id,
                         s.target_id, s.work_package_id, s.year, s.quarter, s.month, s.value, s.plan_value
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
          -- example:
          -- select * from
          -- slice_last_quartered_fact_targets('2021-02-16 20:38:40' :: TIMESTAMP WITHOUT TIME ZONE, '{1,2,3,4}')

          CREATE OR REPLACE FUNCTION first_month_day(pdate date)
              RETURNS date AS
          $$
          SELECT date_trunc('MONTH', pdate)::DATE;
          $$ LANGUAGE 'sql'
              IMMUTABLE STRICT;

          --select first_month_day('2020-02-16 20:38:40')

          CREATE OR REPLACE FUNCTION first_quarter_day(pdate date)
              RETURNS date AS
          $$
          SELECT date_trunc('QUARTER', pdate)::DATE;
          $$ LANGUAGE 'sql'
              IMMUTABLE STRICT;

          --select first_quarter_day('2020-02-16 20:38:40')

          CREATE OR REPLACE FUNCTION min_year_quarter(pyear integer, pquarter integer)
              RETURNS integer AS
          $$
          declare
              ryear int := 0;
              rquarter int := 0 ;
          BEGIN
              ryear := pyear;
              if pquarter = 0 OR pquarter is null OR pquarter > 4 then
                  rquarter := 1;
              else
                  rquarter := pquarter;
              end if;
              return rquarter;
          END
          $$ LANGUAGE plpgsql
          ;
          --select max_year_quarter(2020, 1)

          CREATE OR REPLACE FUNCTION min_quarter_month(pyear integer, pquarter integer, pmonth integer)
              RETURNS integer AS
          $$
          declare
              ryear int := 0;
              rquarter int := 0 ;
              rmonth int := 0;
          BEGIN
              ryear := pyear;
              rquarter:= min_year_quarter(ryear, pquarter);
              if pmonth = 0 OR pmonth is null OR pmonth > 12 then
                  if rquarter = 1 then
                      rmonth := 1;
                  elseif rquarter = 2 then
                      rmonth := 4;
                  elseif rquarter = 3 then
                      rmonth := 7;
                  else
                      rmonth := 10;
                  end if;
              else
                  rmonth := pmonth;
              end if;
              return rmonth;
          END
          $$ LANGUAGE plpgsql
          ;
          CREATE OR REPLACE FUNCTION min_date(pyear integer, pquarter integer, pmonth integer)
              RETURNS date AS
          $$
          declare
              ryear int := 0;
              rquarter int := 0 ;
              rmonth int := 0;
              rdate date;
          BEGIN
              ryear := pyear;
              rquarter:= min_year_quarter(ryear, pquarter);
              rmonth := min_quarter_month(ryear, rquarter, pmonth);
              rdate := make_date(ryear, rmonth, 1);
              return rdate;
          END
          $$ LANGUAGE plpgsql
          ;
          --select min_date(2020, 1, 2), min_date(2019, 4, 12), min_date(2019, 4, null), min_date(2020, null, null), min_date(2020, 1, 0);

          CREATE OR REPLACE FUNCTION slice_first_quartered_plan_targets(slice_date TIMESTAMP WITHOUT TIME ZONE, projects integer[])
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
                                     where min_date(tev.year, tev.quarter, 0) >= first_quarter_day(slice_date :: DATE)
                       ),
          --              slice as (select t.project_id, t.target_id, t.year, min(min_year_quarter(t.year, t.quarter)) as quarter
                       slice as (select t.project_id, t.target_id, min(min_date(t.year,t.quarter,null)) as slice_date
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
                                                  (tev.target_id, min_date(tev.year, tev.quarter,null))
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
          --   slice_first_quartered_plan_targets('2021-02-16' :: TIMESTAMP WITHOUT TIME ZONE, '{1,2,3,4}')
          -- ;
    SQL
  end
end
