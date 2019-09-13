class CommunicationRequirement < ActiveRecord::Base

  belongs_to :stakeholder # заинтересованная сторона
  belongs_to :project


end
