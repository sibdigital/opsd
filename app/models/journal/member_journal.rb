class Journal::MemberJournal < Journal::BaseJournal
  self.table_name = 'member_journals'
end

::MemberJournal = Journal::MemberJournal
