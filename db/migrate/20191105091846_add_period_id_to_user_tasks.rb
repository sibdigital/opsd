class AddPeriodIdToUserTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :user_tasks, :period_id, :integer
  end
end
