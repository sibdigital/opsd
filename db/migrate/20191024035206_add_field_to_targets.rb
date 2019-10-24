class AddFieldToTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :national_project_goal, :text # Задача национального проекта (для региональных проектов).
    add_column :targets, :national_project_result, :text # Результат федерального проекта (для региональных проектов).
    add_column :targets, :national_project_charact, :text # Характеристика результата федерального проекта (для региональных проектов).
    add_column :targets, :result_due_date, :date # Срок достижения результата федерального проекта (для региональных проектов).
    add_column :targets, :result_assigned, :integer # Ответственный за достижение результата. ссылка на users

  end
end
