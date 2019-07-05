#-- encoding: UTF-8
#+-xcc 2019.06.23
class Organization < ActiveRecord::Base
    has_many :work_packages, foreign_key: 'organization_id', dependent: :nullify


    validates :name, uniqueness: true
    validates :inn, uniqueness: true

  def option_name
    nil
  end

  def to_s; name end
end
