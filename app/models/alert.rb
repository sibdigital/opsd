class Alert < ActiveRecord::Base
  def self.create_new_pop_up_alert(entityid,entitytype,aboutwhat,createdby,touser)
    Alert.create entity_id: entityid,
                 alert_date: Date.today,
                 entity_type: entitytype,
                 alert_type: "PopUp",
                 about: aboutwhat,
                 created_by: createdby,
                 to_user: touser
  end
end
