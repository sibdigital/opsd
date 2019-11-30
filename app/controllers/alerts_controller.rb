#-- encoding: UTF-8
#+ iag 2019.07.24
class AlertsController < ApplicationController

  WORK_PACKAGE_REPORT_NOTIFY_ASSIGNEE = 1
  DEADLINE_OF_WORK_PACKAGE_IS_APPROACHING = 2
  DEADLINE_OF_WORK_PACKAGE = 3
  DEADLINE_OF_PROJECT_IS_APPROACHING = 4
  DEADLINE_OF_PROJECT = 5

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

  def create_alert(entity_id, alert_date, entity_type, alert_type, to_user, notify_type)
    alert = Alert.new

    alert.entity_id = entity_id
    alert.alert_date = alert_date
    alert.entity_type = entity_type
    alert.alert_type = alert_type
    alert.to_user = to_user
    alert.readed = false;
    alert.notify_type = notify_type

    alert.save
    alert
  end

  def create_if_absent(entity_id, alert_date, entity_type, alert_type, to_user, notify_type)
    fa = Alert.where(entity_id: entity_id, entity_type: entity_type, alert_type: alert_type,
                     to_user: to_user, notify_type: notify_type).first
    if (fa.nil?)
      create_alert(entity_id, alert_date, entity_type, alert_type, to_user, notify_type)
    end
  end

  def notify_work_package_report_notify_assignee
    if Setting.is_notified_event('work_package_report_notify_assignee')
      wps = WorkPackage.find_by_sql("SELECT Work_Packages.* FROM Work_Packages where
            (
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
      wps.each do |workPackage|
        unless workPackage.assigned_to_id.nil?
          create_if_absent(workPackage.id, Date.current, 'WorkPackage', 'Email',
                           workPackage.assigned_to_id, WORK_PACKAGE_REPORT_NOTIFY_ASSIGNEE)
          end
        end
      end
      #puts (' deadline_of_work_package_is_approaching: ' + Setting.is_notified_event('deadline_of_work_package_is_approaching').to_s)
  end

  def notify_deadline_of_work_package_is_approaching
    if Setting.is_notified_event('deadline_of_work_package_is_approaching')
      wps = WorkPackage.find_by_sql("
      SELECT Work_Packages.* FROM Work_Packages
      where
      (
        (Work_Packages.due_date - CURRENT_DATE) < '#{Setting.remaining_count_days.to_i}' and Work_Packages.due_date > CURRENT_DATE
      )
      ")
      wps.each do |workPackage|
        puts (' workPackage: ' + workPackage.id.to_s)
        unless workPackage.assigned_to_id.nil?
          create_if_absent(workPackage.id, Date.current, 'WorkPackage', 'Email',
                           workPackage.assigned_to_id, DEADLINE_OF_WORK_PACKAGE_IS_APPROACHING)
        end
      end
    end
  end

  def notify_deadline_of_work_package
    if Setting.is_notified_event('deadline_of_work_package')
      wps = WorkPackage.find_by_sql("
      SELECT Work_Packages.* FROM Work_Packages
      where
      (
        Work_Packages.due_date <= CURRENT_DATE
      )")

      wps.each do |workPackage|

        unless workPackage.assigned_to_id.nil?
          create_if_absent(workPackage.id, Date.current, 'WorkPackage', 'Email',
                           workPackage.assigned_to_id, DEADLINE_OF_WORK_PACKAGE)
        end
      end
    end
  end

  def notify_deadline_of_project_is_approaching
    if Setting.is_notified_event('deadline_of_project_is_approaching')
      ps = Project.find_by_sql("
      SELECT projects.* FROM projects
      where
        (cast(projects.due_date as date) - CURRENT_DATE) < '#{Setting.remaining_count_days.to_i}'
         and cast(projects.due_date as date) > CURRENT_DATE ")

      ps.each do |project|
        recip = Setting.is_strong_notified_event('deadline_of_project_is_approaching') ? project.all_recipients : project.recipients
        recip.uniq.each do |user|
          create_if_absent(project.id, Date.current, 'Project', 'Email', user.id, DEADLINE_OF_PROJECT_IS_APPROACHING)
        end
      end
    end
  end

  def notify_deadline_of_project
    if Setting.is_notified_event('deadline_of_project')
      ps = Project.find_by_sql("
      SELECT projects.* FROM projects
      where (cast(projects.due_date as date) <= CURRENT_DATE)");

      ps.each do |project|
        recip = Setting.is_strong_notified_event('deadline_of_project') ? project.all_recipients : project.recipients
        recip.uniq.each do |user|
          create_if_absent(project.id, Date.current, 'Project', 'Email', user.id, DEADLINE_OF_PROJECT)
        end
      end
    end
  end

  def notify_dict
    # tan 2019.11.30 временно закомментировал
    #ban: обязательная отправка напоминаний о вводе данных в справочники (
    # @alerts_array = []
    # @user_tasks = UserTask.find_by_sql("SELECT User_tasks.* FROM User_tasks LEFT JOIN
    # (SELECT alerts.* FROM alerts WHERE alerts.entity_type = 'UserTask' AND alerts.alert_type = 'Email') as al ON User_tasks.id = al.entity_id where
    # (
    # al.entity_id IS NULL
    # and (SELECT
    #              CASE WHEN name='#{I18n.t("default_period_daily")}' THEN cast(date_trunc('day', current_date) as date)
    #                   WHEN name='#{I18n.t("default_period_weekly")}' THEN cast(date_trunc('week', current_date) as date)
    #                   WHEN name='#{I18n.t("default_period_monthly")}' THEN cast(date_trunc('month', current_date) as date)
    #                   WHEN name='#{I18n.t("default_period_quarterly")}' THEN cast(date_trunc('quarter', current_date) as date)
    #                   WHEN name='#{I18n.t("default_period_yearly")}' THEN cast(date_trunc('year', current_date) as date)
    #                   ELSE cast(date_trunc('month', current_date) as date)
    #                  END
    #          FROM enumerations as enum WHERE enum.id = User_tasks.period_id) = CURRENT_DATE and User_tasks.due_date > CURRENT_DATE
    # )")
    # @user_tasks.each do |user_task|
    #   unless user_task.assigned_to_id.nil?
    #     @ut_assignee = User.find_by(id: user_task.assigned_to_id)
    #     #@ut_term_date = user_task.due_date
    #     begin
    #       UserMailer.user_task_period(@ut_assignee, user_task).deliver_later
    #     rescue Exception => e
    #       Rails.logger.info(e.message)
    #     end
    #     @alert = Alert.new
    #     @alert.entity_id = user_task.id
    #     @alerts_array << @alert.entity_id.to_s
    #     #puts user_task.id, ' entity_id: ', @alert.entity_id
    #     @alert.alert_date = Date.current
    #     @alert.entity_type = 'UserTask'
    #     @alert.alert_type = 'Email'
    #     @alert.to_user = @ut_assignee.id
    #     @alert.save
    #   end
    # end
    # if @alerts_array.length > 0
    #   puts 'Создание алертов с типом UserTask (напоминания о вводе данных в справочники). Идентификаторы: '
    #   puts @alerts_array.inspect.to_s
    # end
    # )
  end

  def create_mails
    alrts = Alert.where(readed: false, alert_type: 'Email')
                 .where("alert_date <= ?", Date.current)
    alrts.each do |alert|
      begin
        if alert.notify_type == WORK_PACKAGE_REPORT_NOTIFY_ASSIGNEE || alert.notify_type == DEADLINE_OF_WORK_PACKAGE_IS_APPROACHING ||
          alert.notify_type == DEADLINE_OF_WORK_PACKAGE

          wp = WorkPackage.find(alert.entity_id)
          assigneee = wp.assigned_to
          term_date = wp.due_date
          project_name = wp.project.name

          if alert.notify_type == WORK_PACKAGE_REPORT_NOTIFY_ASSIGNEE
            UserMailer.work_package_report_notify_assignee(assigneee, term_date.to_s, wp, project_name).deliver_later
          elsif alert.notify_type == DEADLINE_OF_WORK_PACKAGE_IS_APPROACHING
            UserMailer.work_package_notify_assignee(assigneee, term_date.to_s, wp, project_name).deliver_later
          elsif alert.notify_type == DEADLINE_OF_WORK_PACKAGE
            UserMailer.work_package_deadline_notify_assignee(assigneee, term_date.to_s, wp, project_name).deliver_later
          end

          alert.readed = true
          alert.save
        end

        if alert.notify_type == DEADLINE_OF_PROJECT_IS_APPROACHING || alert.notify_type == DEADLINE_OF_PROJECT

          project = Project.find(alert.entity_id)
          term_date = project.due_date
          user = User.find(alert.to_user)

          if alert.notify_type == DEADLINE_OF_PROJECT_IS_APPROACHING
            UserMailer.deadline_of_project_is_approaching(user, term_date, project).deliver_later
          elsif alert.notify_type == DEADLINE_OF_PROJECT
            UserMailer.deadline_of_project(user, term_date, project).deliver_later
          end

          alert.readed = true
          alert.save
        end

      rescue Exception => e
        Rails.logger.info(e.message)
      end
    end
  end


  def notify_by_email
    begin
      notify_work_package_report_notify_assignee
    rescue Exception => e
      Rails.logger.info(e.message)
    end

    begin
      notify_deadline_of_work_package_is_approaching
    rescue Exception => e
      Rails.logger.info(e.message)
    end

    begin
      notify_deadline_of_work_package
    rescue Exception => e
      Rails.logger.info(e.message)
    end

    begin
      notify_deadline_of_project_is_approaching
    rescue Exception => e
      Rails.logger.info(e.message)
    end

    begin
      notify_deadline_of_project
    rescue Exception => e
      Rails.logger.info(e.message)
    end

    begin
      notify_dict
    rescue Exception => e
      Rails.logger.info(e.message)
    end

    begin
      create_mails
    rescue Exception => e
      Rails.logger.info(e.message)
    end
    #add method for delete unassigned records
  end


end
