class Journal::ProjectJournal < Journal::BaseJournal
  self.table_name = 'project_journals'

  #+knm
  # before_save :add_project_id
  #-knm

  #+knm
  # def add_project_id
  #   self.project_id = journal.journable_id
  # end

  #-knm
end

::ProjectJournal = Journal::ProjectJournal
