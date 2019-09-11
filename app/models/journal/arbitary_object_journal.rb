class Journal::ArbitaryObjectJournal < Journal::BaseJournal
  self.table_name = 'arbitary_object_journals'
end

::ArbitaryObjectJournal = Journal::ArbitaryObjectJournal
