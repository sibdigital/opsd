module UserTasksHelper

  include OpenProject::StaticRouting

  def children_options_for_select_wp(container, selected = nil)
    return container if String === container
    selected, disabled = extract_selected_and_disabled(selected).map do |r|
      Array(r).map(&:to_s)
    end
    container.map do |element|
      html_attributes = option_html_attributes(element)
      text, value = option_text_and_value(element).map(&:to_s)

      html_attributes[:selected] ||= option_value_selected?(value, selected)
      html_attributes[:disabled] ||= disabled && option_value_selected?(value, disabled)
      html_attributes[:value] = value
      html_attributes[:id] = element[1]
      tag_builder.content_tag_string(:option, text, html_attributes)
    end.join("\n").html_safe
  end

  def self.user_task_collection(user_id = nil, user_type = nil)
    user_tasks = []
    if user_id != nil
      records = if user_type.to_s == 'creator' then UserTask.where(user_creator_id: user_id) else UserTask.where(assigned_to_id: user_id) end
    else
      records = UserTask.all
    end
    records.map do |ut|
        stroka = Hash.new
        stroka['id'] = ut.id
        stroka['kind'] = ut.kind
        stroka['user_creator_id'] = ut.user_creator_id
        stroka['assigned_to_id'] = ut.assigned_to_id
        stroka['object_id'] = ut.object_id
        stroka['object_type'] = ut.object_type
        stroka['text'] = ut.text

        stroka['object'] = ut.object_link(ut)
        stroka['project'] = ut.project
        stroka['project_id'] = ut.project_id
        stroka['related_task'] = ut.related_task
        stroka['related_task_id'] = ut.related_task_id

        stroka['created_at'] = ut.created_at.strftime("%d.%m.%Y")
        stroka['due_date'] = ut.due_date
        stroka['project_name'] = ut.project ? ut.project.name : ''
        stroka['project'] = if ut.project_id.nil? || ut.project_id == 0
                              "#"
                            else
                              StaticUrlHelpers.new.project_url(Project.find_by(id: ut.project_id))
                            end
        stroka['object_name'] = ut.object_name(ut)
        stroka['user_creator_object'] = ut.user_creator
        stroka['user_creator'] = ut.user_creator.name :lastname_f_p

        stroka['assigned_to_object'] = ut.assigned_to
        stroka['assigned_to'] = ut.assigned_to ? ut.assigned_to.name(:lastname_f_p) : ''
        stroka['completed'] = ut.completed ? 'Да' : 'Нет'

        user_tasks << stroka
    end

    user_tasks
  end


end
