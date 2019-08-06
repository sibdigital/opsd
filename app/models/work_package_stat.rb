class WorkPackageStat < ActiveRecord::Base
  self.table_name = "v_work_package_stat"
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :project
  belongs_to :work_package, foreign_key: 'id'

end
