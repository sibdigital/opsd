class WorkPackageLink < ActiveRecord::Base
  belongs_to :work_package
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
end

