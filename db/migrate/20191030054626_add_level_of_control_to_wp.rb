class AddLevelOfControlToWp < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :control_level, :integer
    add_column :work_package_journals, :control_level, :integer
  end
end
