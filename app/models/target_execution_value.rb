class TargetExecutionValue < ActiveRecord::Base

  default_scope { order("#{TargetExecutionValue.table_name}.position ASC") }

  belongs_to :target

  scope :at_target, ->(target_id) {
    where(target_id: target_id)
  }

  acts_as_list scope: 'type = \'#{type}\' and target_id = \'#{target_id}\''

#  validates_presence_of :value
#  validates_length_of :value, maximum: 100 #не знаю зачем, но пусть будет

  def self.inherited(child)
    child.instance_eval do
      def model_name
        TargetExecutionValue.model_name
      end
    end
    super
  end

  def option_name
    nil
  end



  def to_s; id end
end
