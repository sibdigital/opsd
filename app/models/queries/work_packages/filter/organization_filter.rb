class Queries::WorkPackages::Filter::OrganizationFilter < Queries::WorkPackages::Filter::WorkPackageFilter

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
