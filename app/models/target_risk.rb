class TargetRisk < ActiveRecord::Base
  belongs_to :target
  belongs_to :risk

  def option_name
    nil
  end

  def to_s
    id.to_s
  end
end
