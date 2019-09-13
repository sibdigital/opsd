class TargetCalcProcedure < ActiveRecord::Base

  belongs_to :target # целевой показатель, для которого приводится методика
  belongs_to :project
  belongs_to :user # ответственный
  belongs_to :base_target, class_name: "Target", foreign_key: "base_target_id" # базовый целевой показатель, т.е на его основе ведется расчет

end
