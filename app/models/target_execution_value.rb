class TargetExecutionValue < ActiveRecord::Base
  belongs_to :target

  #validates :quarter
  validates :quarter, uniqueness: { scope: :year, scope: :target_id,
                                    message: "Значение за указанный квартал уже присутствует",
                                    case_sensitive: false}
  def option_name
    nil
  end

  def to_s
    id.to_s
  end
end
