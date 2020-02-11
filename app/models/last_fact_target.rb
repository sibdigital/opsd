class LastFactTarget
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Model
  extend ActiveModel::Naming

  attr_accessor :national_project_id, :federal_project_id, :project_id, :target_id, :work_package_id,
                :year, :quarter, :month, :value, :plan_value

  def initialize(attributes={})
    attributes.each do |name, value|
      send("#{name}=",value)
    end
  end

  def self.get(projects, time = Date.today)
    results = ActiveRecord::Base.connection.exec_query(
      "select * from slice_last_quartered_fact_targets('#{time}' :: TIMESTAMP WITHOUT TIME ZONE, '{#{projects}}')"
    )
    answer = []
    results.each do |result|
      answer << initialize(result)
    end
  end
end
