class Journal::MemberRoleJournal < Journal::BaseJournal
  self.table_name = 'member_role_journals'
  # +knm
  # before_save :add_project_id
  # # -knm
  #
  # # +knm
  # def add_project_id
  # end
  # -knm
end

::MemberRoleJournal = Journal::MemberRoleJournal
