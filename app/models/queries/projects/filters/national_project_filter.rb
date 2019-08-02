#bbm

class Queries::Projects::Filters::NationalProjectFilter < Queries::Projects::Filters::ProjectFilter
  self.model = Project

  def human_name
    'Национальный проект'
  end

  def type
    :integer
  end

  def self.key
    :national_project_id
  end

  def name
    :national_project_id
  end

  def where
    operator_strategy.sql_for_field(values, "projects", self.class.key)
  end
end
