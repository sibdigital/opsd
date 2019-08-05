
class Queries::WorkPackages::Filter::RaionFilter < ::Queries::WorkPackages::Filter::WorkPackageFilter

  def type
    :integer
  end

  def human_name
    WorkPackage.human_attribute_name('raion_id')
  end

  def self.key
    :raion_id
  end

  def allowed_values
    values || []
  end

  def ar_object_filter?
    true
  end

  def available?
    true
  end

  def where
    operator_strategy.sql_for_field(values, self.class.model.table_name, self.class.key)
  end

end
