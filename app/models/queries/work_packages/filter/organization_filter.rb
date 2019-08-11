
class Queries::WorkPackages::Filter::OrganizationFilter < ::Queries::WorkPackages::Filter::WorkPackageFilter

  #self.model = Organization
  def type
    :list_optional#:integer
  end

  def human_name
    WorkPackage.human_attribute_name('organization_id')
  end

  def self.key
    :organization_id
  end

  def allowed_values
    org = User.current.organization
    if org != nil
      childs = org.childs().map { |r| [r.name, r.id.to_s] }
    # else
    #   childs = [['', 0]]
    end
    childs || []
  end

  def value_objects
    int_values = values.map(&:to_i)
    int_values
  end

  def ar_object_filter?
    true
  end

  def available?
    true
  end

end
