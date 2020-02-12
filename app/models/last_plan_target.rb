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
      "select * from slice_last_quartered_plan_targets('{#{projects}}')"
    ).to_hash
  end

  def self.get_end(project)
    ActiveRecord::Base.connection.exec_query(
      "select * from slice_last_quartered_plan_targets('{#{project.id}}')"
    ).to_hash
  end
end
