#-- encoding: UTF-8
#+-xcc 2019.06.23
class Organization < ActiveRecord::Base
    has_many :org_controlling, foreign_key: 'org_controlling_id', dependent: :nullify
    has_many :org_performer, foreign_key: 'org_performer_id', dependent: :nullify

    validates :name, uniqueness: true
    validates :inn, uniqueness: true

  def option_name
    nil
  end

  def to_s; name end
end
