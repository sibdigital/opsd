
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
    # o = Organization.all.map{ |r| [r.name, r.id.to_s]  }
    # oa = o.to_a
    # oa
    org = User.current.organization
    if org != nil
      childs = org.childs().map { |r| [r.name, r.id.to_s] }
    else
      childs = [['', 0]]
    end
    childs
    #childs = org != nil ? org.childs()#.map {|c| c.id.to_i} : [0]
    #Organization.all { |r| [r.name, r.id.to_s]  }.to_a#values || []
  end

  # def value_objects
  #   int_values = values.map(&:to_i)
  #   int_values
  # end

  # def value_objects
  #   values || []
  # end

  def ar_object_filter?
    true
  end

  def available?
    true
  end

  # def where
  #   operator_strategy.sql_for_field(values, self.class.model.table_name, self.class.key)
  # end

  ##
  # def self.key
  #   :organization_id
  # end
end
