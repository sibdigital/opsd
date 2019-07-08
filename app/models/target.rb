class Target < ActiveRecord::Base
  belongs_to :project
  belongs_to :target_status, foreign_key: 'status_id'
  belongs_to :target_type, foreign_key: 'type_id'
  has_many :target_execution_values, dependent: :destroy

  def option_name
    nil
  end

  def to_s
    name
  end
end
