class WorkPackageContract < ActiveRecord::Base
  belongs_to :contract
  belongs_to :work_package

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
end
