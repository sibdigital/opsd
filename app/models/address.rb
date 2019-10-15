class Address < ActiveRecord::Base
  self.table_name = "addresses"
  belongs_to :project
end

