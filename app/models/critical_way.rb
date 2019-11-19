class CriticalWay < ActiveRecord::Base
  belongs_to :work_package, class_name: 'WorkPackage', foreign_key: 'wp_id'
end
