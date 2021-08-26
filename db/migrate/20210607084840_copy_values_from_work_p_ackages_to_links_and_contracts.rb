class CopyValuesFromWorkPAckagesToLinksAndContracts < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      insert into work_package_links (work_package_id, link, name, updated_at, created_at, author_id)
      select id, sed_href, sed_href, now(), now(), author_id from work_packages where sed_href notnull;

      insert into work_package_contracts (work_package_id, contract_id, comment, updated_at, created_at, author_id)
      select id, contract_id, '', now(), now(), author_id from work_packages where contract_id notnull;
    SQL
  end
end
