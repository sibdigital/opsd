class FirstPlanTarget
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

  def self.get_now(projects, time = Date.today)
    ActiveRecord::Base.connection.exec_query(
      "select * from slice_first_quartered_plan_targets('#{time}' :: TIMESTAMP WITHOUT TIME ZONE, '{#{projects}}')"
    ).to_hash
  end

  def self.get_previous_quarter(projects, time = Date.today)
    ActiveRecord::Base.connection.exec_query(
      "select * from slice_first_quartered_plan_targets((first_quarter_day('#{time}') - INTERVAL  '1 day'), '{#{projects}}')"
    ).to_hash
  end

  def self.get_next_quarter(projects, time = Date.today)
    ActiveRecord::Base.connection.exec_query(
      "select * from slice_first_quartered_plan_targets((last_quarter_day('#{time}') + INTERVAL  '1 day'), '{#{projects}}')"
    ).to_hash
  end
end
