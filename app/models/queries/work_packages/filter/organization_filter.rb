
class Queries::WorkPackages::Filter::OrganizationFilter < ::Queries::WorkPackages::Filter::WorkPackageFilter

  attr_reader :organization_values, :allowed_organization_values

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
    childs = allowed_organization_values.map { |r| [r.name, r.id.to_s] }
    childs || []
  end

  def values=(values)
    org = Organization.find_by(id: values)
    if org != nil
      @values = org.childs(true).map {|c| c.id.to_s}
    else
      @values = Array(values).map(&:to_s)
    end
  end

  def value_objects
    int_values = values.map(&:to_i)
    organization_values.select { |c| int_values.include?(c.id) }
  end

  def organization_values
    @organization_values ||= allowed_organization_values
  end

  def allowed_organization_values
    if !User.current.has_priveleged?(@project) && !User.current.admin? && !User.current.detect_project_office_coordinator? && !User.current.detect_project_administrator?
      org = User.current.organization
      @allowed_organization_values = org != nil ? org.childs() : []
    else
      @allowed_organization_values = Organization.all
    end
  end

  def ar_object_filter?
    true
  end

  def available?
    true
  end

end
