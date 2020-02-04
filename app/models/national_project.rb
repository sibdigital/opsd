class NationalProject < ActiveRecord::Base
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице
  acts_as_journalized
  has_many :projects, foreign_key: "national_project_id"
  has_many :projects_federal, foreign_key: "federal_project_id", class_name: "Project"
  has_many :agreements, foreign_key: 'national_project_id'
  # bbm( исправил следующую строку т.к. по-моему она не должна была работать
  has_many :agreements_federal, foreign_key: 'federal_project_id'
  # )

  has_many :national_work_package_quarterly_targets, -> { where(type: 'National') }, foreign_key: 'national_project_id', class_name: "WorkPackageQuarterlyTarget"
  has_many :national_plan_fact_yearly_target_values, -> { where(type: 'National') }, foreign_key: 'national_project_id', class_name: "PlanFactYearlyTargetValue"
  has_many :national_plan_quarterly_target_values, -> { where(type: 'National') }, foreign_key: 'national_project_id', class_name: "PlanQuarterlyTargetValue"
  has_many :national_plan_fact_quarterly_target_values, -> { where(type: 'National') }, foreign_key: 'national_project_id', class_name: "PlanFactQuarterlyTargetValue"

  has_many :federal_work_package_quarterly_targets, -> { where(type: 'Federal') }, foreign_key: 'federal_project_id', class_name: "WorkPackageQuarterlyTarget"
  has_many :federal_plan_fact_yearly_target_values, -> { where(type: 'Federal') }, foreign_key: 'federal_project_id', class_name: "PlanFactYearlyTargetValue"
  has_many :federal_plan_quarterly_target_values, -> { where(type: 'Federal') }, foreign_key: 'federal_project_id', class_name: "PlanQuarterlyTargetValue"
  has_many :federal_plan_fact_quarterly_target_values, -> { where(type: 'Federal') }, foreign_key: 'federal_project_id', class_name: "PlanFactQuarterlyTargetValue"

  def to_s
    name
  end

  def self.visible_federal_projects(current_user)
    slq = <<-SQL
            select distinct np.*
            from national_projects as np
            inner join(
              select project_id, national_project_id, federal_project_id
              from members as m
              inner join projects as p
              on p.id = m.project_id
              where user_id = ?
              ) as mu
            on (np.id = mu.federal_project_id and np.parent_id = mu.national_project_id)
    SQL
    nps = NationalProject.find_by_sql([slq, current_user.id])
    nps
  end

  def self.visible_national_projects(current_user)
    slq = <<~SQL
      select distinct np.*
      from national_projects as np
      inner join(
        select DISTINCT national_project_id
        from members as m
          inner join projects as p
            on p.id = m.project_id
        where user_id = ?
      ) as mu
      on (np.id = mu.national_project_id);
    SQL
    nps = NationalProject.find_by_sql([slq, current_user.id])
    nps
  end

  def self.visible_national_federal_projects(current_user)
    slq = <<~SQL
      select distinct np.*
      from national_projects as np
        inner join(
          select project_id, national_project_id, federal_project_id
          from members as m
                   inner join projects as p
                              on p.id = m.project_id
          where user_id = ?
        ) as mu
        on ((np.id = mu.federal_project_id and np.parent_id = mu.national_project_id) or (np.id = mu.national_project_id))
    SQL
    nps = NationalProject.find_by_sql([slq, current_user.id])
    nps
  end

  def self.visible_national_projects_with_problems(current_user)
    slq = <<~SQL
      select distinct np.*
      from national_projects as np
             inner join(
        select DISTINCT project_id, national_project_id, federal_project_id
        from members as m
                 inner join projects as p
                            on p.id = m.project_id
        where user_id = ?
      ) as mu
        on ((np.id = mu.federal_project_id and np.parent_id = mu.national_project_id) or (np.id = mu.national_project_id))
             left join v_project_risk_on_work_packages_stat as vprowps
                       on (np.id = vprowps.national_project_id or np.id = vprowps.federal_project_id)
      where vprowps.type = 'created_problem' or vprowps.type = 'created_risk'
    SQL
    nps = NationalProject.find_by_sql([slq, current_user.id])
    nps
  end

  def self.national_projects
    NationalProject.where(type: ['National', 'Default'])
  end

  def self.federal_projects
    NationalProject.where(type: 'Federal')
  end

  def self.default_project
    NationalProject.find_by(type: 'Default').id
  end
end
