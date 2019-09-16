class Journal::NationalProjectJournal < Journal::BaseJournal
  self.table_name = 'national_project_journals'
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

end

::NationalProjectJournal = Journal::NationalProjectJournal
