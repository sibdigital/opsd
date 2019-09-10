class StakeholderOrganization < Stakeholder::Base

  belongs_to :target # целевой показатель, для которого приводится методика
  belongs_to :project
  belongs_to :organization # ответственный

end
