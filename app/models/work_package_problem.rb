class WorkPackageProblem < ActiveRecord::Base

  belongs_to :risk, class_name: 'ProjectRisk'
  belongs_to :project
  belongs_to :work_package

  belongs_to :user_creator, class_name: 'User'
  belongs_to :user_source_id, class_name: 'User'
  belongs_to :organization_source, class_name: 'Organization'

end
