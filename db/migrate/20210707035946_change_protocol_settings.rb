class ChangeProtocolSettings < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      update settings set value = 'http' where name = 'protocol';
    SQL
  end
end
