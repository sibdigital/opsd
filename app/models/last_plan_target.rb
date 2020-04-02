class LastPlanTarget
  include ActiveModel::Validations
  include ActiveModel::Model
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :national_project_id, :federal_project_id, :project_id, :target_id,
                :year, :quarter, :value

  def initialize(attributes={})
    attributes.each do |name, value|
      send("#{name}=",value)
    end
  end

  def self.get_now(projects)
    ActiveRecord::Base.connection.exec_query(
      "select * from slice_last_quartered_plan_targets('#{Date.today}' :: TIMESTAMP WITHOUT TIME ZONE, '{#{projects}}')"
    ).to_hash
  end

  def self.get_by_date(projects, time)
    ActiveRecord::Base.connection.exec_query(
      "select * from slice_last_quartered_plan_targets('#{time}' :: TIMESTAMP WITHOUT TIME ZONE, '{#{projects}}')"
    ).to_hash
  end

  def self.get_ends(projects)
    time = Date.new(3000, 12, 31)
    ActiveRecord::Base.connection.exec_query(
      "select * from slice_last_quartered_plan_targets('#{time}' :: TIMESTAMP WITHOUT TIME ZONE, '{#{projects}}')"
    ).to_hash
  end
end
