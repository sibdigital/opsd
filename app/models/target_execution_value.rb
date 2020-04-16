class TargetExecutionValue < ActiveRecord::Base
  belongs_to :target

  #validates :quarter
  validates :year, uniqueness: { scope: [:target_id, :quarter],
                                    message: "Значение за указанный год уже присутствует"
                                }
  validates_each :quarter do |record, attr, value|
    if value.nil?
      if TargetExecutionValue.where("year = ? and target_id = ? and quarter is null", record.year, record.target_id).count.positive?
        record.errors.add(attr, "Значение за год уже присутствует")
      end
    else
      if TargetExecutionValue.where("year = ? and target_id = ? and quarter = ?", record.year, record.target_id, value).count.positive?
        record.errors.add(attr, "Значение за квартал уже присутствует")
        #Target.errors.add(attr, "Значение за квартал уже присутствует")
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
