class Raion < ActiveRecord::Base
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице
  has_many :work_packages, foreign_key: 'raion_id', dependent: :nullify

  def to_s
    name
  end

  def self.projects_by_id(raion_id, projects)
    sql = "
      select *
      FROM (select *
            from projects as p
            where  p.id in (:projects)
        ) as p
      inner join(
        select distinct project_id
        from work_packages as w
        WHERE w.raion_id = :raion_id
      ) as w
      on p.id = w.project_id
    "
    Project.find_by_sql [sql, {:projects => projects, :raion_id => raion_id}]
  end

  def self.projects_by_id_by_user(raion_id, user)
    projects = []
    user.projects.each do |p|
      if p.type == Project::TYPE_PROJECT
        projects << p.id
      end
    end
    sql = <<~SQL
      select *
      FROM (select *
            from projects as p
            where  p.id in (?)
        ) as p
      inner join(
        select distinct project_id
        from work_packages as w
        WHERE w.raion_id = ?
      ) as w
      on p.id = w.project_id
    SQL
    Project.find_by_sql([sql, projects, raion_id])
  end

end
