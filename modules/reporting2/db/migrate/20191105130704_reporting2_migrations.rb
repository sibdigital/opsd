class Reporting2Migrations < ActiveRecord::Migration[5.1]

  def up
    create_table "target_queries", id: :integer do |t|
      t.integer  "user_id",                                       :null => false
      t.integer  "project_id"
      t.string   "name",                                          :null => false
      t.boolean  "is_public",                  :default => false, :null => false
      t.datetime "created_on",                                    :null => false
      t.datetime "updated_on",                                    :null => false
      t.string   "serialized", :limit => 2000,                    :null => false
    end
  end
end
