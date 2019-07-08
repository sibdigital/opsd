class ChangeProjectIdOfTargets < ActiveRecord::Migration[5.2]
  def change
    change_column :targets, :project_id, 'integer using project_id::integer'
  end
end
