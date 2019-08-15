#zbd

class Queries::Projects::Filters::FederalProjectFilter < Queries::Projects::Filters::ProjectFilter
  self.model = Project

  def human_name
    'Федеральный проект'
  end

  def type
    :list_optional
  end

  def self.key
    :federal_project_id
  end

  def name
    :federal_project_id
  end

  def where
    operator_strategy.sql_for_field(values, "projects", self.class.key)
  end

  def allowed_values
    np = NationalProject.where('type = ?', 'Federal')
    if np.present?
      childs = np.map { |r| [r.name, r.id.to_s] }
    end
    childs || []
  end

end
