class WorkPackageQuarterlyTarget < ActiveRecord::Base
  self.table_name = "v_quartered_work_package_targets_with_quarter_groups"
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :target
  belongs_to :project
  belongs_to :work_package
end
