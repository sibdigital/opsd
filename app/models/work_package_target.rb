class WorkPackageTarget < ActiveRecord::Base

  belongs_to :target
  belongs_to :project
  belongs_to :work_package

end
