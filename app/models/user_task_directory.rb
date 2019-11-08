class UserTaskDirectory < Enumeration

  OptionName = :user_task_directory

  def option_name
    OptionName
  end

  def to_s
    name
  end
end
