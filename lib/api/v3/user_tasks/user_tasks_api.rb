require 'api/v3/user_tasks/user_task_collection_representer'
require 'api/v3/user_tasks/user_task_representer'

module API
  module V3
    module UserTasks
      class UserTasksAPI < ::API::OpenProjectAPI
        resources :user_tasks do
          get do
            records_array = ActiveRecord::Base.connection.execute <<~SQL
              select * from user_tasks
            SQL
            @user_tasks = []
            records_array.map do |arr|
              stroka = Hash.new
              stroka['id'] = arr['id']
              stroka['kind'] = arr['kind']
              stroka['user_creator_id'] = arr['user_creator_id']
              stroka['assigned_to_id'] = arr['assigned_to_id']
              stroka['object_type'] = arr['object_type']
              stroka['text'] = arr['text']
              @d = Date.parse(arr['created_at'])
              stroka['created_at'] = @d.strftime("%d.%m.%Y")
              stroka['due_date'] = arr['due_date']
              if arr['project_id'] != nil
                @project_link = project_url(Project.find_by(id: arr['project_id']))
                @project_name = Project.find_by(id: arr['project_id']).name
              else
                @project_link = "#"
                @project_name = nil
              end
              if arr['object_type'] = "WorkPackage" and arr['object_id'] != nil
                @wp_link = work_package_url(WorkPackage.find_by(id: arr['object_id']))
                @wp_name = WorkPackage.find_by(id: arr['object_id']).name
              else
                @wp_link = "#"
                @wp_name = nil
              end
              stroka['project'] = @project_link.to_s
              stroka['object'] = @wp_link.to_s
              stroka['project_name'] = @project_name
              stroka['object_name'] = @wp_name
              @user_creator = User.find_by(id: arr['user_creator_id']).lastname.to_s
              stroka['user_creator'] = @user_creator
              if arr['assigned_to_id'] != nil
                @assigned_to = User.find_by(id: arr['assigned_to_id']).lastname.to_s
              else
                @assigned_to = nil
              end
              stroka['assigned_to'] = @assigned_to
              @user_tasks << stroka
            end
            @user_tasks
          end
        end
      end
    end
  end
end
