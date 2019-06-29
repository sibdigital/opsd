#-- encoding: UTF-8
#+-hss 2019.06.23
class Organization < ActiveRecord::Base
    validates :name, uniqueness: true
    validates :inn, uniqueness: true

  def option_name
    nil
  end

  def to_s; name end
end
