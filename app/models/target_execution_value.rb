class TargetExecutionValue < ActiveRecord::Base
  belongs_to :target

  #validates :quarter
  #validates :quarter, uniqueness: { scope: :year, scope: :target_id,
  #                                  message: "Значение за указанный квартал уже присутствует",
  #                                  case_sensitive: false}
  validates_each :quarter do |record, attr, value|
    if value.nil?
      if TargetExecutionValue.where("year = ? and target_id = ? and quarter is null", record.year, record.target_id).count > 0
        record.errors.add(attr, "Значение за указанный период уже присутствует")
      end
    else
      if TargetExecutionValue.where("year = ? and target_id = ? and quarter = ?", record.year, record.target_id, value).count > 0
        record.errors.add(attr, "Значение за указанный квартал уже присутствует")
      end
    end
  end

  def option_name
    nil
  end

  def to_s
    id.to_s
  end
end
