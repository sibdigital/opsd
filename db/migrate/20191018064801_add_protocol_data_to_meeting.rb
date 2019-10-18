class AddProtocolDataToMeeting < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :chairman_id, :integer # сслыка на users - председатель совещания
    add_column :meetings, :add_participants, :text # дополнительные участники строкой
    add_column :meetings, :speakers, :text # те, кто выступил
  end
end
