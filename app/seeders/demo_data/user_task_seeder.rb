#-- encoding: UTF-8
# This file written by BAN
# 03/11/2019

module DemoData
  class UserTaskSeeder < Seeder
    def seed_data!
      UserTask.transaction do
        data.each do |attributes|
          UserTask.create!(attributes)
        end
      end
    end

    def applicable?
      UserTask.all.empty?
    end

    def not_applicable_message
      'Skipping user_tasks as there are already some configured'
    end

    def data
      [
        { project_id: Project.find_by(identifier: 'cultura').id, user_creator_id: user_by_login('admin').id, assigned_to_id: user_by_login('admin').id, object_id: wp_by_subject.id, object_type: "WorkPackage", kind: "Request", text: "Текст запроса на приемку задачи", due_date: "2020-01-01"},
        { user_creator_id: user_by_login('admin').id, assigned_to_id: user_by_login('admin').id, object_type: "Типовые риски", kind: "Request", text: "Текст запроса на редактирование справочника Типовые риски", due_date: "2020-01-01"},
        { user_creator_id: user_by_login('admin').id, kind: "Note", text: "Текст заметки"},
        { project_id: Project.find_by(identifier: 'cultura').id, user_creator_id: user_by_login('admin').id, assigned_to_id: user_by_login('admin').id, object_id: wp_by_subject.id, object_type: "WorkPackage", kind: "Task", text: "Текст задачи", due_date: "2020-01-01"},
        { project_id: Project.find_by(identifier: 'cultura').id, user_creator_id: user_by_login('admin').id, assigned_to_id: user_by_login('admin').id, object_id: wp_by_subject.id, object_type: "WorkPackage", kind: "Response", text: "Текст ответа по задаче", due_date: "2020-01-01", related_task_id: 4},
        { project_id: Project.find_by(identifier: 'cultura').id, user_creator_id: user_by_login('admin').id, assigned_to_id: user_by_login('admin').id, object_id: wp_by_subject.id, object_type: "WorkPackage", kind: "Response", text: "Текст ответа на запрос", due_date: "2020-01-01", related_task_id: 1}
      ]
    end

    def user_by_login(login)
      np = User.find_by(login: login)
      if np != nil
        np
      end
    end

    def wp_by_subject
      np = WorkPackage.find_by(subject: 'Утверждена проектно-сметная документация по строительству центров культурного развития в городах с числом жителей до 300 000 человек')
      if np != nil
        np
      end
    end

  end
end

