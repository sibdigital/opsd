
class Queries::WorkPackages::Filter::RaionFilter <
  ::Queries::WorkPackages::Filter::WorkPackageFilter

  attr_reader :raions

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
    values  = raions.map { |r| [r.name, r.id.to_s]  }
    values || []
  end

  def values=(values)
    @values = Array(values).map(&:to_s)
  end

  def value_objects
    int_values = values.map(&:to_i)

    raions.select { |c| int_values.include?(c.id) }
  end

  def ar_object_filter?
    true
  end

  def available?
    true
  end

  private

  def raions
    @raions ||= Raion.all || []
  end

end
