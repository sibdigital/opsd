class ChangeDueDateToBeTimestampInUserTasks < ActiveRecord::Migration[5.2]
  def change
    change_column :user_tasks, :due_date, :timestamp
  end
end
