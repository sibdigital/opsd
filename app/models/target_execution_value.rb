class TargetExecutionValue < ActiveRecord::Base


  belongs_to :target


  def option_name
    nil
  end

  def to_s
    id.to_s
  end
end
