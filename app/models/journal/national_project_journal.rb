class Journal::NationalProjectJournal < Journal::BaseJournal
  self.table_name = 'national_project_journals'
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице
  #+knm
  # before_save :add_project_id
  #-knm

  #+knm
  # def add_project_id
  #   self.project_id = journal.journable_id
  # end

  #-knm
end

::NationalProjectJournal = Journal::NationalProjectJournal
