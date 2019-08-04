
class Queries::WorkPackages::Filter::OrganizationFilter < ::Queries::WorkPackages::Filter::WorkPackageFilter

  #self.model = Organization

  def type
    :integer
  end

  def human_name
    WorkPackage.human_attribute_name('organization_id')
  end

  def self.key
    :organization_id
  end

  def allowed_values
    values || []
  end

  # def value_objects
  #   values || []
  # end

  def ar_object_filter?
    true
  end

  def available?
    true
  end

  def where
    operator_strategy.sql_for_field(values, self.class.model.table_name, self.class.key)
  end

  ##
  # def self.key
  #   :organization_id
  # end
end
