class OrganizationType < Enumeration

  OptionName = :enumeration_organization_type

  def option_name
    OptionName
  end

  def to_s
    name
  end
end
