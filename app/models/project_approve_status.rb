class ProjectApproveStatus < Enumeration

  #has_many :projects, foreign_key: 'project_approve_status_id'

  OptionName = :project_approve_status

  def option_name
    OptionName
  end

  def to_s
    name
  end
end
