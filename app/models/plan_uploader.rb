class PlanUploader < ActiveRecord::Base
  mount_uploader :name, XlsUploader
end
