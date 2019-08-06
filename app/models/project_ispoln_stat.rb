class ProjectIspolnStat < ActiveRecord::Base
  self.table_name = "v_project_ispoln_stat"
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :project
  belongs_to :national_project, -> { where(type: 'National') }, class_name: "NationalProject", foreign_key: "national_project_id"
  belongs_to :federal_project, -> { where(type: 'Federal') }, class_name: "NationalProject", foreign_key: "federal_project_id"

end
