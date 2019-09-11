#written by ban
class UserTask < ActiveRecord::Base

  belongs_to :project, class_name: "Project", foreign_key: "project_id"
  belongs_to :user_creator, class_name: "User", foreign_key: "user_creator_id"
  belongs_to :assigned_to, class_name: "User", foreign_key: "assigned_to_id"

end
