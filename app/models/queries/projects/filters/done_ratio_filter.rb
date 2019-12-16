#tmd
class Queries::Projects::Filters::DoneRatioFilter < Queries::Projects::Filters::ProjectFilter
  self.model = Project

  def human_name
    'Процент исполнения'
  end

  def type
    :list
  end

  def name
    :done_ratio
  end

  def self.key
    :done_ratio
  end

  def allowed_values
    result = model.get_all_ratio

    if result.present?
      ratio = result.map { |s| [s.done_ratio, s.done_ratio] }
    end
    ratio || []
  end

  def where
    value = values[0]
    sql = "floor(coalesce((with
            rels as (
                select from_id, to_id
                from relations as r
                where  hierarchy > 0 and from_id <> to_id
            )
                ,
            only_childs as(
                select distinct to_id as child_id
                from rels
            ),
            wp as(
                select id, done_ratio
                from work_packages as w
                where project_id = projects.id
            ),
            rels_wp as( select distinct w.id as id, from_id
                        from wp as w
                                 inner join rels as r
                                            on w.id = from_id
            ),
            done_wp as( select distinct w.id as id, done_ratio, from_id, child_id
                        from wp as w
                                 left join rels_wp as r
                                           on w.id = from_id
                                 left join only_childs as o
                                           on w.id = o.child_id
            ),
            only_parents as (select *
                             from done_wp as r
                             where r.child_id is null or (not r.from_id is null and r.child_id is null)
            )
        select avg(done_ratio) from only_parents), 0)) = " + value
  end
end

