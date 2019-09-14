class CreateAdditionalJournals < ActiveRecord::Migration[5.2]
  def change
    create_table :member_journals do |t|
      t.integer :journal_id, null: false
      t.integer :user_id, default: 0, null: false
      t.integer :project_id, default: 0, null: false
      t.datetime :created_on
      t.boolean :mail_notification, default: false, null: false
      t.index [:journal_id]
    end
    create_table :member_role_journals do |t|
      t.integer :journal_id, null: false
      t.integer :member_id, null: false
      t.integer :role_id, null: false
      t.integer :inherited_from
      t.index [:journal_id]
    end
    create_table :user_journals do |t|
      t.integer :journal_id, null: false
      t.string :login, limit: 256, default: '', null: false
      t.string :firstname, limit: 30, default: '', null: false
      t.string :lastname, limit: 30, default: '', null: false
      t.string :mail, limit: 60, default: '', null: false
      t.boolean :admin, default: false, null: false
      t.integer :status, default: 1, null: false
      t.datetime :last_login_on
      t.string :language, limit: 5, default: ''
      t.integer :auth_source_id
      t.datetime :created_on
      t.datetime :updated_on
      t.string :type
      t.string :identity_url
      t.string :mail_notification, default: '', null: false
      t.boolean :first_login, null: false, default: true
      t.boolean :force_password_change, default: false
      t.integer :failed_login_count, default: 0
      t.datetime :last_failed_login_on, null: true
      t.datetime :consented_at
      t.integer :organization_id
      t.integer :position_id
      t.string :patronymic, limit: 30
      t.string :phone_wrk, limit: 14
      t.string :phone_wrk_add, limit: 6
      t.string :phone_mobile, limit: 12
      t.string :mail_add, limit: 60
      t.string :address, limit: 160
      t.string :cabinet, limit: 6
      t.index [:journal_id]
    end
    create_table :group_user_journals do |t|
      t.integer :journal_id, null: false
      t.integer :group_id, null: false
      t.integer :user_id, null: false
      t.index [:journal_id]
    end
    create_table :risk_journals do |t|
      t.integer :journal_id, null: false
      t.integer :project_id
      t.string :name
      t.text :description
      t.integer :possibility_id
      t.integer :importance_id
      t.string :type
      t.integer :color_id
      t.integer :owner_id
      t.boolean :is_possibility, default: false
      t.boolean :is_approve
      t.index [:journal_id]
    end
    create_table :risk_charact_journals do |t|
      t.integer :journal_id, null: false
      t.integer :risk_id
      t.string :name
      t.text :description
      t.string :type
      t.integer :position
      t.index [:journal_id]
    end
    create_table :position_journals do |t|
      t.integer :journal_id, null: false
      t.string :name
      t.boolean :is_approve
      t.index [:journal_id]
    end
    create_table :organization_journals do |t|
      t.integer :journal_id, null: false
      t.bigint :parent_id
      t.string :name
      t.string :inn
      t.boolean :is_legal_entity
      t.integer :org_type
      t.boolean :is_approve
      t.index [:journal_id]
    end
    create_table :arbitary_object_journals do |t|
      t.integer :journal_id, null: false
      t.string :name
      t.integer :type_id
      t.integer :project_id
      t.boolean :is_approve
      t.index [:journal_id]
    end
    create_table :board_journals do |t|
      t.integer :journal_id, null: false
      t.integer :project_id, null: false
      t.string :name, default: '', null: false
      t.string :description
      t.integer :position, default: 1
      t.integer :topics_count, default: 0, null: false
      t.integer :messages_count, default: 0, null: false
      t.integer :last_message_id
      t.index [:journal_id]
    end
    add_column :journals, :project_id, :integer
    add_column :journals, :is_deleted, :boolean, default: false
    add_index :journals, :project_id
  end
end
