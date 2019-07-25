class TargetExecutionValue < ActiveRecord::Base
  belongs_to :target

  #validates :quarter

  def option_name
    nil
  end

  def to_s
    id.to_s
  end
end
