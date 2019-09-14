class Journal::RiskCharactJournal < Journal::BaseJournal
  self.table_name = 'risk_charact_journals'
  self.inheritance_column = nil
end

::RiskCharactJournal = Journal::RiskCharactJournal
