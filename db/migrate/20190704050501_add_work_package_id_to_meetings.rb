class AddWorkPackageIdToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :work_package_id, :integer
  end
end
