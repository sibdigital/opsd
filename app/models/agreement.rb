class Agreement < ActiveRecord::Base
  belongs_to :project

  def option_name
    nil
  end

  def to_s
    number_agreement
  end
end
