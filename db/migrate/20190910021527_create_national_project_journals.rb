class CreateNationalProjectJournals < ActiveRecord::Migration[5.2]
  def change
    create_table :national_project_journals do |t|
      t.integer :journal_id
      t.string :name # наименование проекта
      t.string :leader # ФИО руководителя проекта
      t.string :leader_position # должность руководителя проекта
      t.string :type # тип: National - национальный, Federal - федеральный
      t.integer :parent_id # идентификатор родителя. Всего есть 12 нац проектов у них родителей нет, все федеральные проекты
      # входят в нац проекты то есть для федерального проекта parent_id указывается
      t.string :curator # ФИО куратор
      t.string :curator_position # должность куратора
      t.datetime :start_date # дата начала
      t.datetime :due_date # дата завершения
      t.string :description # описание
      t.timestamps
    end
  end
end
