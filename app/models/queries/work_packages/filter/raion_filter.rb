
class Queries::WorkPackages::Filter::RaionFilter <
  ::Queries::WorkPackages::Filter::WorkPackageFilter

  def type
    :list_optional#:integer
  end

  def human_name
    WorkPackage.human_attribute_name('raion_id')
  end

  def self.key
    :raion_id
  end

  def allowed_values
    values  = Raion.all { |r| [r.name, r.id.to_s]  }
    values
    #values || []
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

  # def where
  #   operator_strategy.sql_for_field(values, self.class.model.table_name, self.class.key)
  # end

end
