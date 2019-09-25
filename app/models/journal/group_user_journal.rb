class Journal::GroupUserJournal < Journal::BaseJournal
  self.table_name = 'group_user_journals'
end

::GroupUserJournal = Journal::GroupUserJournal
