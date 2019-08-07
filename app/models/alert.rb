class Alert < ActiveRecord::Base
  def self.create_new_pop_up_alert(entityid,entitytype,aboutwhat,createdby,touser)
    text = ""
    user_created=User.where(id: createdby).map {|u| [u.lastname, u.firstname, u.patronymic]}

    case aboutwhat
    when "Due"
      text += "Истекает срок исполнения мероприятия "
    when "Created"
      text += "Создана новая запись в таблице "
    when "Changed"
      text += "Была изменена запись в таблице "
    when "Moved"
      text += "Запись была перенесена в другую таблицу "
    when "Deleted"
      text += "Была удалена запись из таблицы "
    end

    case entitytype
    when "Boards"
      text += "Дискусии"
    when "WorkPackages"
      text += "Мероприятия"
    when "News"
      text += "Новости"
    when "Projects"
      text += "Проекты"
    when "Members"
      text += "Участники"
    end

    if createdby.zero?
      text += ". Cоздано системой в"
    else
      text += ". Cоздано " + user_created[0][0] + " "
      if user_created[0][1]!= nil
        text += user_created[0][1].slice(0...1) + ". "
      end
      if user_created[0][2]!= nil
        text += user_created[0][2].slice(0...1) + ". "
      end
      text += "в "
    end
    text += Time.current.to_formatted_s(:time)
    Alert.create entity_id: entityid,
                 alert_date: Date.today,
                 entity_type: entitytype,
                 alert_type: "PopUp",
                 about: text,
                 created_by: createdby,
                 to_user: touser
  end
end
