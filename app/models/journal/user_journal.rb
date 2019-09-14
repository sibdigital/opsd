class Journal::UserJournal < Journal::BaseJournal
  self.table_name = 'user_journals'
  self.inheritance_column = nil
end

::UserJournal = Journal::UserJournal
