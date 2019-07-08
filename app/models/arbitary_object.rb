class ArbitaryObject < ActiveRecord::Base
  belongs_to :project

  belongs_to :arbitary_object_type, foreign_key: 'type_id'

  has_many :work_packages, foreign_key: 'arbitary_object_id'

  def option_name
    nil
  end

  def to_s
    name
  end
end
