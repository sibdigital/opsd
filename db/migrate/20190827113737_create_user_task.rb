class CreateUserTask < ActiveRecord::Migration[5.2]
  def change
    #Таблица задач
    # Используется для задач пользователя, размещаемых в календаре
    # И для запросов или отказов от запросов
    create_table :user_tasks do |t|
      t.integer :user_creator_id # идентификатор пользователя-создателя задачи
      t.integer :assigned_to_id  # кому назначена задача
      t.integer :object_id       # связанный объект системы: work_package или справочник - госконтракт, организация
      t.string  :object_type     # тип объекта WorKPackage, Organization - т.е имя модели
      t.string  :kind            # тип задачи:
                                 # Task - задача пользователя для календаря, связана с объектом Системы
                                 # Note - заметка
                                 # Request - запрос
                                 # Response - ответ на запрос
      t.string  :text            # Тект задачи, может формироваться как пользователем так и автоматически по шаблону
      t.date    :due_date        # Дата завершения задачи
      t.boolean :completed       # Признак завершения
      t.integer :related_task_id       # Связанная задача

      t.timestamps
    end
  end
end
