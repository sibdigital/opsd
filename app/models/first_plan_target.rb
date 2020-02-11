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

  def self.get(projects, time = Date.today)
    results = ActiveRecord::Base.connection.exec_query(
      "select * from slice_first_quartered_plan_targets('#{time}' :: TIMESTAMP WITHOUT TIME ZONE, '{#{projects}}')"
    )
    answer = []
    results.each do |result|
      answer << initialize(result)
    end
  end
end
