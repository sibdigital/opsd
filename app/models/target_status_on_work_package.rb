class TargetStatusOnWorkPackage < ActiveRecord::Base
  self.table_name = "v_target_status_on_work_package"
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :target
  belongs_to :project
  belongs_to :work_package, foreign_key: 'id'
  belongs_to :national_project, -> { where(type: 'National') }, class_name: "NationalProject", foreign_key: "national_project_id"
  belongs_to :federal_project, -> { where(type: 'Federal') }, class_name: "NationalProject", foreign_key: "federal_project_id"

end
