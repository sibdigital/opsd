class AddProjectStatusToProjects < ActiveRecord::Migration[5.2]
  def change
    #tan(
    # эти статусы необходимы для того, чтобы соблюсти требования ТТ (стр 27) - ProjectStatus
    # ProjectApproveStatus - для соблюдения 469 постановления, чтобы с помощью эжтого статуса можно было проводить
    # согласование
    # поле status используется чтобы передавать проект в архив т.е могут быть завершенные проекты, но в архив их
    # передавать еще рано, например по ним проводится анализ или есть связанные с ними проекты
    add_column :projects, :project_approve_status_id, :integer
    add_column :projects, :project_status_id, :integer
  end
end
