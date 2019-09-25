class Journal::OrganizationJournal < Journal::BaseJournal
  self.table_name = 'organization_journals'
end

::OrganizationJournal = Journal::OrganizationJournal
