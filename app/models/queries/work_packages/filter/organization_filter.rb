class Queries::WorkPackages::Filter::OrganizationFilter < Queries::WorkPackages::Filter::WorkPackageFilter
  # def allowed_values
  #   a=1
  # end

  def type
    :list
  end

  def self.key
    :organization_id
  end

  ##
  # def self.key
  #   :organization_id
  # end
end
