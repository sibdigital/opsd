class Agreement < ActiveRecord::Base
  belongs_to :project
  belongs_to :national_project, foreign_key: 'national_project_id'
  belongs_to :national_project, foreign_key: 'federal_project_id'

  def option_name
    nil
  end

  def to_s
    number_agreement
  end
end
