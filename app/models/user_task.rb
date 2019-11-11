#written by ban
class UserTask < ActiveRecord::Base

  include AccessibilityHelper
  include OpenProject::StaticRouting

  belongs_to :project, class_name: "Project", foreign_key: "project_id"
  belongs_to :user_creator, class_name: "User", foreign_key: "user_creator_id"
  belongs_to :assigned_to, class_name: "User", foreign_key: "assigned_to_id"
  belongs_to :related_task, class_name: "UserTask", foreign_key: "related_task_id"

  def object_link(ut)
    object_link = "#"
    case ut.object_type
    when "WorkPackage"
      object_link = (ut.object_id.nil? || ut.object_id == 0) ? "#" : StaticUrlHelpers.new.work_package_url(WorkPackage.find_by(id: ut.object_id))
    when "Производственные календари"
      object_link = "/production_calendars"
    when "Типовые риски"
      object_link = "/admin/typed_risks"
    when "Типовые результаты"
      object_link = "/admin/typed_targets"
    when "Уровни контроля"
      object_link = "/admin/control_levels"
    when "Перечисления"
      object_link = "/admin/enumerations"
    when "Типы расходов"
      object_link = "/cost_types"
    when "Национальные проекты"
      object_link = "/national_projects"
    when "Государственные программы"
      object_link = "/national_projects/government_programs"
    end
    object_link
  end

  def object_name(ut)
    _object_name = ut.object_type
    if ut.object_type == "WorkPackage" && ut.object_id
      _object_name = WorkPackage.find_by(id: ut.object_id).name
    end
    _object_name
  end

end
