#tmd
class Queries::Projects::Filters::ProjectApproveStatusFilter < Queries::Projects::Filters::ProjectFilter
  self.model = Project

  def human_name
    'Этап согласования'
  end

  def type
    :list
  end

  def self.key
    :project_approve_status_id
  end

  def name
    :project_approve_status_id
  end

  def allowed_values
    project_approve_status = ProjectApproveStatus.all
    if project_approve_status.present?
      childs = project_approve_status.map { |s| [s.name, s.id.to_s] }
    end
    childs || []
  end

  def where
    operator_strategy.sql_for_field(values, "projects", self.class.key)
  end
end

