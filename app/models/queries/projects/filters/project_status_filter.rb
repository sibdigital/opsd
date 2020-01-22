#tmd
class Queries::Projects::Filters::ProjectStatusFilter < Queries::Projects::Filters::ProjectFilter
  self.model = Project

  def human_name
    'Статус'
  end

  def type
    :list
  end

  def self.key
    :project_status_id
  end

  def name
    :project_status_id
  end

  def allowed_values
    project_status = ProjectStatus.all
    if project_status.present?
      childs = project_status.map { |s| [s.name, s.id.to_s] }
    end
    childs || []
  end

  def where
    operator_strategy.sql_for_field(values, "projects", self.class.key)
  end

  def order
    9
  end
end
