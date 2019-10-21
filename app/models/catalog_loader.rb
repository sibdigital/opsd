class CatalogLoader < ActiveRecord::Base
  mount_uploader :name, XlsUploader
end
