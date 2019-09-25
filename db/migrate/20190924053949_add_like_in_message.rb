class AddLikeInMessage < ActiveRecord::Migration[5.2]
  def change
    # возможность ставить лайки сообщениям
    create_table :message_likes do |t|
      t.integer :message_id
      t.integer :user_id, default: 0

      t.timestamps
    end

    #описание документа с возможностью отражения автора
    add_column :documents, :user_id, :integer
    add_column :document_journals, :user_id, :integer

    #описание документа со связанной дискуссией
    add_column :messages, :document_id, :integer
    add_column :message_journals, :document_id, :integer

    #последний ip-адрес пользователя
    add_column :users, :last_ip, :string
  end
end
