class WorkPackageContract < ActiveRecord::Base
  belongs_to :contract
  belongs_to :work_package

  belongs_to :user_creator, class_name: 'User'
end
