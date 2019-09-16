class Journal::RiskJournal < Journal::BaseJournal
  self.table_name = 'risk_journals'
  self.inheritance_column = nil
end

::RiskJournal = Journal::RiskJournal
