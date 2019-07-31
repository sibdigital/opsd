#-- encoding: UTF-8
#+ iag 2019.07.24
class AlertsController < ApplicationController

  # layout 'admin'

  #before_action :require_admin
  #before_action :find_organization, only: [:edit, :update, :destroy]
  respond_to :html, :json

  #protect_from_forgery with: :exception
  #include OrgSettingsHelper

  def index
    notify_by_email

    # render json: @alerts.select([:id, :entity_id, :entity_type, :alert_date])
    render html: "AlertsController выполнен"
  end


  def new
    @emailNotify = EmailNotify.new
  end

  def get_dues
    # @due_wp=WorkPackage.where(due_date: )
  end

  def get_pop_up_alerts
    @alerts=Alert.where(alert_type: 'PopUp').where(to_user: User.current.id).where(readed: false)
    if Alert.where(alert_type: 'PopUp').count.positive?
      # render plain: Alert.where(alert_type: 'PopUp').count
      render json: @alerts
    end
    # render plain: "OK"
  end

  def get_delay_setting
    delay=Setting.find_by(name: 'notify_delay')

    render plain: delay.value
  end

  def read_alert
    alert=Alert.find_by_id(params["pop_id"])
    alert.readed=true
    alert.save
  end

  def notify_by_email

=begin
    @WorkPackages = WorkPackage.left_outer_joins(" LEFT JOIN alerts ON WorkPackage.id = alerts.entity_id where
      (alerts.entity_id is null and days(WorkPackage.due_date - CURRENT_DATE) < 14)
       OR ( (days(alerts.last_date) + 3) <= CURRENT_DATE)");
=end
=begin
    @WorkPackages = WorkPackage.find_by_sql("SELECT  * FROM WorkPackages LEFT JOIN alerts ON WorkPackage.id = alerts.entity_id where
      (alerts.entity_id is null and days(WorkPackage.due_date - CURRENT_DATE) < 14)
       OR ( (days(alerts.last_date) + 3) <= CURRENT_DATE)");
=end

    @WorkPackages = WorkPackage.find_by_sql("SELECT Work_Packages.* FROM Work_Packages LEFT JOIN alerts ON Work_Packages.id = alerts.entity_id where
    (alerts.entity_id is null and (Work_Packages.due_date - CURRENT_DATE) < 14)
    OR ( (alerts.alert_date + 3) <= CURRENT_DATE) ");

    #puts(@WorkPackages.size)

    @WorkPackages.each do |workPackage|

      unless workPackage.assigned_to_id.nil?
        @assigneee = User.find(workPackage.assigned_to_id);

        UserMailer.work_package_notify_assignee(@assigneee).deliver_later
        #UserMailer.work_package_notify_assignee(@assigneee).deliver_now
        Alert.create_new_pop_up_alert(workPackage.id, 'WorkPackage', "Due", 0, workPackage.author_id)
        @alert = Alert.new

        @alert.entity_id = workPackage.id
        puts workPackage.id, ' entity_id: ', @alert.entity_id

        @alert.alert_date = Date.current
        @alert.entity_type = 'WorkPackage'
        @alert.alert_type = 'Email'

        @alert.save

        #puts workPackage.due_date, ' ', workPackage.assigned_to_id, ' ', 'to delayed job.';
      end
    end



    #add method for delete unassigned records


  end
end
