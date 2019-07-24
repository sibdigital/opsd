class CreateNationalProject < ActiveRecord::Migration[5.2]
  def change
    #таблица национальных и федеральных проектов
    create_table :national_projects do |t|
      t.string :name # наименование проекта
      t.string :leader # ФИО руководителя проекта
      t.string :leader_position # должность руководителя проекта
      t.string :type # тип: National - национальный, Federal - федеральный
      t.integer :parent_id # идентификатор родителя. Всего есть 12 нац проектов у них родителей нет, все федеарльные проекты входят в
      # нац проекты то есть для федерального проекта parent_id указывается
      t.string :curator # ФИО куратор
      t.string :curator_position # должность куратора
      t.datetime :start_date # дата начала
      t.datetime :due_date # дата завершения
      t.string :description # описание

      t.timestamps
    end

    add_column :projects, :start_date, :datetime # добавим в проект дату начала
    add_column :projects, :due_date, :datetime # добавим в проект дату завершения
    add_column :projects, :national_project_id, :integer # добавим нац проект в проект
    add_column :projects, :federal_project_id, :integer # добавим федеральный проект в проект
  end
end
