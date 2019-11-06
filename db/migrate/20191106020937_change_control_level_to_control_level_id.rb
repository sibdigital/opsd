class ChangeControlLevelToControlLevelId < ActiveRecord::Migration[5.2]
  def change
    change_table :work_packages do |t|
      t.rename :control_level, :control_level_id
    end
    change_table :work_package_journals do |t|
      t.rename :control_level, :control_level_id
    end
  end
end
