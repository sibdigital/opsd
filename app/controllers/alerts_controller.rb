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
    if Alert.where(alert_type: 'PopUp', readed: false).count.positive?
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
    if Setting.notified_events.include?('work_package_report_notify_assignee')
      @WorkPackages = WorkPackage.find_by_sql("SELECT Work_Packages.* FROM Work_Packages LEFT JOIN
                            (SELECT alerts.* FROM alerts WHERE alerts.entity_type = 'WorkPackage' AND alerts.alert_type = 'Email') as al ON Work_Packages.id = al.entity_id where
    (
            al.entity_id IS NULL
            and
            (SELECT
                 CASE WHEN name='#{I18n.t("default_period_daily")}' THEN cast(date_trunc('day', current_date) as date)
                      WHEN name='#{I18n.t("default_period_weekly")}' THEN cast(date_trunc('week', current_date) as date)
                      WHEN name='#{I18n.t("default_period_monthly")}' THEN cast(date_trunc('month', current_date) as date)
                      WHEN name='#{I18n.t("default_period_quarterly")}' THEN cast(date_trunc('quarter', current_date) as date)
                      WHEN name='#{I18n.t("default_period_yearly")}' THEN cast(date_trunc('year', current_date) as date)
                      ELSE cast(date_trunc('month', current_date) as date)
                     END
             FROM enumerations as enum WHERE enum.id = Work_Packages.period_id) = CURRENT_DATE and Work_Packages.due_date > CURRENT_DATE
        )")
      @WorkPackages.each do |workPackage|

        unless workPackage.assigned_to_id.nil?
          @assigneee = User.find(workPackage.assigned_to_id)
          @term_date = workPackage.due_date #ban
          @project_name = Project.find_by(id: workPackage.project_id).name #ban

          begin
            UserMailer.work_package_report_notify_assignee(@assigneee,@term_date.to_s,workPackage,@project_name).deliver_now #ban
          rescue Exception => e
            Rails.logger.info(e.message)
          end

          #UserMailer.work_package_notify_assignee(@assigneee).deliver_now
          #Alert.create_pop_up_alert(workPackage,  "Due", nil, workPackage.assigned_to)
          @alert = Alert.new

          @alert.entity_id = workPackage.id
          puts workPackage.id, ' entity_id: ', @alert.entity_id

          @alert.alert_date = Date.current
          @alert.entity_type = 'WorkPackage'
          @alert.alert_type = 'Email'
          @alert.to_user = @assigneee.id

          @alert.save
        end
      end
    end
    if Setting.notified_events.include?('deadline_of_work_package_is_approaching')
      @WorkPackages = WorkPackage.find_by_sql("
      SELECT Work_Packages.* FROM Work_Packages LEFT JOIN
      (SELECT alerts.* FROM alerts WHERE alerts.entity_type = 'WorkPackage' AND alerts.alert_type = 'Email') as al ON Work_Packages.id = al.entity_id where
      (
        al.entity_id IS NULL
        and
        (Work_Packages.due_date - CURRENT_DATE) < '#{Setting.remaining_count_days.to_i}' and Work_Packages.due_date > CURRENT_DATE
      )
      OR ( (al.alert_date + 1) <= CURRENT_DATE)
      ");

      #puts(@WorkPackages.size)

      @WorkPackages.each do |workPackage|

        unless workPackage.assigned_to_id.nil?
          @assigneee = User.find(workPackage.assigned_to_id)
          @term_date = workPackage.due_date #ban
          @project_name = Project.find_by(id: workPackage.project_id).name #ban

          begin
            UserMailer.work_package_notify_assignee(@assigneee,@term_date.to_s,workPackage,@project_name).deliver_now #ban
          rescue Exception => e
            Rails.logger.info(e.message)
          end

          #UserMailer.work_package_notify_assignee(@assigneee).deliver_now
          #Alert.create_pop_up_alert(workPackage,  "Due", nil, workPackage.assigned_to)
          @alert = Alert.new

          @alert.entity_id = workPackage.id
          puts workPackage.id, ' entity_id: ', @alert.entity_id

          @alert.alert_date = Date.current
          @alert.entity_type = 'WorkPackage'
          @alert.alert_type = 'Email'
          @alert.to_user = @assigneee.id

          @alert.save

          #puts workPackage.due_date, ' ', workPackage.assigned_to_id, ' ', 'to delayed job.';
        end
      end
    end

    if Setting.notified_events.include?('deadline_of_work_package')
      @WorkPackagesDeadline = WorkPackage.find_by_sql("
      SELECT Work_Packages.* FROM Work_Packages LEFT JOIN
      (SELECT alerts.* FROM alerts WHERE alerts.entity_type = 'WorkPackageDeadline' AND alerts.alert_type = 'Email') as al ON Work_Packages.id = al.entity_id where
      (
        al.entity_id IS NULL
        and
        Work_Packages.due_date <= CURRENT_DATE
      )
      OR ( (al.alert_date + 1) <= CURRENT_DATE)
      ");

      @WorkPackagesDeadline.each do |workPackage|

        unless workPackage.assigned_to_id.nil?
          @assigneee = User.find(workPackage.assigned_to_id)
          @term_date = workPackage.due_date
          @project_name = Project.find_by(id: workPackage.project_id).name

          begin
            UserMailer.work_package_deadline_notify_assignee(@assigneee,@term_date.to_s,workPackage,@project_name).deliver_now
          rescue Exception => e
            Rails.logger.info(e.message)
          end

          #Alert.create_new_pop_up_alert(workPackage.id, 'WorkPackagesDue', "Due", 0, workPackage.assigned_to_id)
          @alert = Alert.new

          @alert.entity_id = workPackage.id
          puts workPackage.id, ' entity_id: ', @alert.entity_id

          @alert.alert_date = Date.current
          @alert.entity_type = 'WorkPackageDeadline'
          @alert.alert_type = 'Email'
          @alert.to_user = @assigneee.id

          @alert.save

          #puts workPackage.due_date, ' ', workPackage.assigned_to_id, ' ', 'to delayed job.';
        end
      end
    end

    if Setting.notified_events.include?('deadline_of_project_is_approaching')
      @Projects = Project.find_by_sql("
      SELECT projects.* FROM projects LEFT JOIN
      (SELECT alerts.* FROM alerts WHERE alerts.entity_type = 'Project' AND alerts.alert_type = 'Email') as al ON projects.id = al.entity_id where
      (
        al.entity_id IS NULL
        and
        (cast(projects.due_date as date) - CURRENT_DATE) < '#{Setting.remaining_count_days.to_i}' and cast(projects.due_date as date) > CURRENT_DATE
      )
      OR ( (al.alert_date + 1) <= CURRENT_DATE)
      ");

      @Projects.each do |project|

        project.recipients.uniq.each do |user|
          @term_date = project.due_date

          begin
            UserMailer.deadline_of_project_is_approaching(user, @term_date, project).deliver_now
          rescue Exception => e
            Rails.logger.info(e.message)
          end


          #puts workPackage.due_date, ' ', workPackage.assigned_to_id, ' ', 'to delayed job.';
        end
        @alert = Alert.new

        @alert.entity_id = project.id
        puts project.id, ' entity_id: ', @alert.entity_id

        @alert.alert_date = Date.current
        @alert.entity_type = 'Project'
        @alert.alert_type = 'Email'

        @alert.save
      end
    end

    if Setting.notified_events.include?('deadline_of_project')
      @Projects = Project.find_by_sql("
      SELECT projects.* FROM projects LEFT JOIN
      (SELECT alerts.* FROM alerts WHERE alerts.entity_type = 'ProjectDeadline' AND alerts.alert_type = 'Email') as al ON projects.id = al.entity_id where
      (
        al.entity_id IS NULL
        and
        cast(projects.due_date as date) <= CURRENT_DATE
      )
      OR ( (al.alert_date + 1) <= CURRENT_DATE)
      ");

      @Projects.each do |project|

        project.recipients.uniq.each do |user|
          @term_date = project.due_date
          begin
            UserMailer.deadline_of_project(user, @term_date, project).deliver_now
          rescue Exception => e
            Rails.logger.info(e.message)
          end


          #puts workPackage.due_date, ' ', workPackage.assigned_to_id, ' ', 'to delayed job.';
        end
        @alert = Alert.new

        @alert.entity_id = project.id
        puts project.id, ' entity_id: ', @alert.entity_id

        @alert.alert_date = Date.current
        @alert.entity_type = 'ProjectDeadline'
        @alert.alert_type = 'Email'

        @alert.save
      end
    end

    #ban: обязательная отправка напоминаний о вводе данных в справочники (
    @user_tasks = UserTask.find_by_sql("SELECT User_tasks.* FROM User_tasks LEFT JOIN
    (SELECT alerts.* FROM alerts WHERE alerts.entity_type = 'UserTask' AND alerts.alert_type = 'Email') as al ON User_tasks.id = al.entity_id where
    (
    al.entity_id IS NULL
    and (SELECT
                 CASE WHEN name='#{I18n.t("default_period_daily")}' THEN cast(date_trunc('day', current_date) as date)
                      WHEN name='#{I18n.t("default_period_weekly")}' THEN cast(date_trunc('week', current_date) as date)
                      WHEN name='#{I18n.t("default_period_monthly")}' THEN cast(date_trunc('month', current_date) as date)
                      WHEN name='#{I18n.t("default_period_quarterly")}' THEN cast(date_trunc('quarter', current_date) as date)
                      WHEN name='#{I18n.t("default_period_yearly")}' THEN cast(date_trunc('year', current_date) as date)
                      ELSE cast(date_trunc('month', current_date) as date)
                     END
             FROM enumerations as enum WHERE enum.id = User_tasks.period_id) = CURRENT_DATE and User_tasks.due_date > CURRENT_DATE
    )")
    @user_tasks.each do |user_task|
      unless user_task.assigned_to_id.nil?
        @ut_assignee = User.find_by(id: user_task.assigned_to_id)
        #@ut_term_date = user_task.due_date
        begin
          UserMailer.user_task_period(@ut_assignee, user_task).deliver_now
        rescue Exception => e
          Rails.logger.info(e.message)
        end
        @alert = Alert.new
        @alert.entity_id = user_task.id
        puts user_task.id, ' entity_id: ', @alert.entity_id
        @alert.alert_date = Date.current
        @alert.entity_type = 'UserTask'
        @alert.alert_type = 'Email'
        @alert.to_user = @ut_assignee.id
        @alert.save
      end
    end
    # )

    #add method for delete unassigned records


  end
end
