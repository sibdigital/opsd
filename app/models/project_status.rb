class ProjectStatus < Enumeration

  #has_many :projects#, class_name: 'Project', foreign_key: 'project_status_id'

  OptionName = :project_status

  def option_name
    OptionName
  end

  def to_s
    name
  end
end
