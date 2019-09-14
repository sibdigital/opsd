class Journal::PositionJournal < Journal::BaseJournal
  self.table_name = 'position_journals'
end

::PositionJournal = Journal::PositionJournal
