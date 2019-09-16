class Journal::BoardJournal < Journal::BaseJournal
  self.table_name = 'board_journals'
end

::BoardJournal = Journal::BoardJournal

