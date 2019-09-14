#-- encoding: UTF-8
# This file written by BBM
# 29/04/2019
#
class RiskCharact < ActiveRecord::Base
  default_scope { order("#{RiskCharact.table_name}.position ASC") }

  belongs_to :risk

  scope :at_risk, ->(risk_id) {
    where(risk_id: risk_id)
  }
  acts_as_journalized

  acts_as_list scope: 'type = \'#{type}\' and risk_id = \'#{risk_id}\''

  validates_presence_of :name
  validates_length_of :name, maximum: 30 #не знаю зачем, но пусть будет

  def self.inherited(child)
    child.instance_eval do
      def model_name
        RiskCharact.model_name
      end
    end
    super
  end

  def self.colored?
    false
  end

  def option_name
    nil
  end

  def <=>(risk_charact)
    position <=> risk_charact.position
  end

  def to_s; name end
end

# Force load the subclasses in development mode
%w(risk_effect risk_measure).each do |enum_subclass|
  require_dependency enum_subclass
end
