class Period < Enumeration

  has_many :work_packages, foreign_key: 'period_id', dependent: :nullify#, class_name: 'Project', foreign_key: 'project_status_id'

  def option_name
    OptionName
  end

  def to_s
    name
  end
end
