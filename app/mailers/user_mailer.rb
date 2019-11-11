#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

class UserMailer < BaseMailer

  def test_mail(user)
    @welcome_url = url_for(controller: '/homescreen')

    headers['X-OpenProject-Type'] = 'Test'

    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'ИСУП - тестовое сообщение'
    end
  end
=begin
  def work_package_added(user, journal, author)
    User.execute_as user do
      work_package = journal.journable.reload
      @issue = work_package # instance variable is used in the view
      @journal = journal

      set_work_package_headers(work_package)

      message_id work_package, user

      # Alert.create_new_pop_up_alert(1, "WorkPackages", "Changed", author.id, user.id)
      with_locale_for(user) do
        mail_for_author author, to: user.mail, subject: subject_for_work_package(work_package)
      end
    end
  end
=end
#ban (
  def work_package_added(user, project, work_package, author)
    @project = project
    @work_package = work_package
    set_work_package_headers(work_package)

    message_id work_package, user

    with_locale_for(user) do
      subject = 'В проекте '+@project.name.to_s+' добавлено мероприятие '+@work_package.subject
      mail_for_author author, to: user.mail, subject: subject
    end
  end
#)
  def work_package_updated(user, journal, author = User.current)
    User.execute_as user do
      work_package = journal.journable.reload

      # instance variables are used in the view
      @issue = work_package
      @journal = journal

      set_work_package_headers(work_package)

      message_id journal, user
      references work_package, user

      with_locale_for(user) do
        mail_for_author author, to: user.mail, subject: subject_for_work_package(work_package)
      end
    end
  end

#iag, ban(
  def work_package_notify_assignee(user, term_date, workPackage, project_name)
    #@welcome_url = url_for(controller: '/homescreen')

    #headers['X-OpenProject-Type'] = 'Test'

    @term_date = term_date
    @workPackage = workPackage
    @project_name = project_name
    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'Необходимо исполнить мероприятие '+@workPackage.subject+' по проекту '+project_name
    end
  end
#)

#tan (
  # def notify_forum_notify_assignee(mail)
  #   @welcome_url = url_for(controller: '/homescreen')
  #
  #   headers['X-OpenProject-Type'] = 'Test'
  #
  #   mail to: "\"#{name}\" <#{mail}>", subject: 'Вы приглашены в дискуссию'
  # end

#ban(
  def work_package_deadline_notify_assignee(user, term_date, workPackage, project_name)

    #headers['X-OpenProject-Type'] = 'Test'

    @term_date = term_date
    @workPackage = workPackage
    @project_name = project_name
    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'Превышен срок по пакету работ '+@workPackage.subject+' в проекте '+project_name
    end
  end

  def deadline_of_project_is_approaching(user, term_date, project)

    #headers['X-OpenProject-Type'] = 'Test'

    @term_date = term_date
    @project = project
    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'Приближается срок по проекту '+@project.name
    end
  end

  def deadline_of_project(user, term_date, project)

    #headers['X-OpenProject-Type'] = 'Test'

    @term_date = term_date
    @project = project
    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'Превышен срок по проекту '+@project.name
    end
  end
  # knm +
  def work_package_report_notify_assignee(user, report_date, workPackage, project_name)
    @report_date = report_date
    @workPackage = workPackage
    @project_name = project_name
    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'Необходимо сегодня предоставить отчет по выполнению задачи '+@workPackage.subject+' в проекте '+project_name
    end
  end
  # knm -
  def cost_object_added(user, cost_object, author, timenow)
    @timenow = timenow
    @cost_object = cost_object

    #open_project_headers 'Type'    => 'Cost_objects'
    #open_project_headers 'Project' => @cost_object.project.identifier if @cost_object.project

    message_id @cost_object, user

    with_locale_for(user) do
      subject = 'В проект "'+@cost_object.project.name+'" добавлен бюджет '+@cost_object.subject
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def member_added(user, project, added_user, author, timenow)
    @timenow = timenow
    @project = project
    @added_user = added_user

    #open_project_headers 'Type'    => 'Members'
    #open_project_headers 'Project' => @cost_object.project.identifier if @cost_object.project

    #message_id @project, user

    with_locale_for(user) do
      subject = 'В проект '+@project.name.to_s+' добавлен участник '+@added_user.lastname.to_s+' '+@added_user.firstname.to_s
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def member_deleted(user, project, deleted_user, author, timenow)
    @timenow = timenow
    @project = project
    @deleted_user = deleted_user

    #open_project_headers 'Type'    => 'Members'
    #open_project_headers 'Project' => @cost_object.project.identifier if @cost_object.project

    #message_id @project, user

    with_locale_for(user) do
      subject = 'Из проекта '+@project.name.to_s+' исключен участник '+@deleted_user.lastname.to_s+' '+@deleted_user.firstname.to_s
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def board_added(user, board, author, project, timenow)
    @timenow = timenow
    @board = board
    @project = project
    @url_to_board = Setting.host_name+'/projects/'+@project.name+'/boards/'+@board.id.to_s
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'По проекту "'+@project.name+'" создана дискуссия: '+@board.name
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def board_changed(user, board, author, project, timenow)
    @timenow = timenow
    @board = board
    @project = project
    @url_to_board = Setting.host_name+'/projects/'+@project.name+'/boards/'+@board.id.to_s
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'По проекту "'+@project.name+'" изменена дискуссия: '+@board.name
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def board_moved(user, board, author, project, timenow)
    @timenow = timenow
    @board = board
    @project = project
    @url_to_board = Setting.host_name+'/projects/'+@project.name+'/boards/'+@board.id.to_s
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'По проекту "'+@project.name+'" перемещена дискуссия: '+@board.name
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def board_deleted(user, boardname, author, project, timenow)
    @timenow = timenow
    @boardname = boardname
    @project = project
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'По проекту "'+@project.name+'" удалена дискуссия: '+@boardname
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def news_changed(user, news, author, project, timenow)
    @timenow = timenow
    @news = news
    @project = project
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'В проекте "'+@project.name+'" обновлена новость: '+@news.title
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def news_deleted(user, news, author, project, timenow)
    @timenow = timenow
    @news = news
    @project = project
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'В проекте "'+@project.name+'" удалена новость: '+@news.title
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def project_created(user, project, author)
    @project = project
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Создан проект "'+@project.name+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def project_changed(user, project, author, old_status, old_start_date, old_due_date)
    @project = project
    @old_status = old_status
    @old_start_date = old_start_date
    @old_due_date = old_due_date
    @text = 'Дата обновления: '+@project.updated_on.to_s+'.'
    if @old_status != @project.get_project_status.id
      @text = @text+' Статус проекта: '+@project.get_project_status.name+'.'
    end
    if @old_start_date != @project.start_date.to_s
      @text = @text+' Дата начала проекта: '+@project.start_date.to_s+'.'
    end
    if @old_due_date != @project.due_date.to_s
      @text = @text+' Дата окончания проекта: '+@project.due_date.to_s+'.'
    end
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Изменен проект "'+@project.name+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def project_deleted(user, project, author, timenow)
    @timenow = timenow
    @project = project
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Удален проект "'+@project.name+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def group_created(user, group, author)
    @group = group
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Создана группа "'+@group.name+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def group_deleted(user, groupname, author)
    @groupname = groupname
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Удалена группа "'+@groupname+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def status_created(user, status, author)
    @status = status
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Создан статус "'+@status.name+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def status_deleted(user, statusname, author)
    @statusname = statusname
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Удален статус "'+@statusname+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def type_created(user, type, author)
    @type = type
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Создан тип рабочего пакета "'+@type.name+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def type_deleted(user, typename, author)
    @typename = typename
    #open_project_headers 'Type'    => 'Boards'
    #open_project_headers 'Project' => @project.identifier
    #message_id @project, user

    with_locale_for(user) do
      subject = 'Удален тип рабочего пакета "'+@typename+'"'
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def user_task_request_created(user, url_to_object, begin_text, timenow, due_date, ut_text, ut_creator)
    @url_to_object = url_to_object
    @begin_text = begin_text
    @timenow = timenow
    @due_date = due_date
    @ut_text = ut_text
    @ut_creator = ut_creator

    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'Вам направлен запрос'
    end
  end

  def user_task_period(user, user_task)
    @user_task = user_task

    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'Вам направлен запрос'
    end
  end
#)

  def work_package_notify_assignee1(user, work_package , author = User.current)
    User.execute_as user do
      # instance variables are used in the view
      @issue = work_package

      set_work_package_headers(work_package)

      references work_package, user

      with_locale_for(user) do
        mail_for_author author, to: user.mail, subject: subject_for_work_package(work_package)
      end
    end
  end

  def reply_to_message_notify(user)
    @welcome_url = url_for(controller: '/homescreen')

    headers['X-OpenProject-Type'] = 'Test'

    with_locale_for(user) do
      mail to: "\"#{user.name}\" <#{user.mail}>", subject: 'Ответьте на сообщение в дискуссии.'
    end
  end
# )

  def work_package_watcher_added(work_package, user, watcher_setter)
    User.execute_as user do
      @issue = work_package
      @watcher_setter = watcher_setter

      set_work_package_headers(work_package)
      message_id work_package, user
      references work_package, user

      with_locale_for(user) do
        mail to: user.mail, subject: subject_for_work_package(work_package)
      end
    end
  end

  #bbm(
  def password_lost_new_password(user, newpass)

    @newpass = newpass
    @user = user

    open_project_headers 'Type' => 'Account'

    with_locale_for(user) do
      subject = t(:mail_subject_lost_password, value: Setting.app_title)
      mail to: user.mail, subject: subject
    end
  end
  # )
  def password_lost(token)
    return unless token.user # token's can have no user

    @token = token
    @reset_password_url = url_for(controller: '/account',
                                  action:     :lost_password,
                                  token:      @token.value)

    open_project_headers 'Type' => 'Account'

    user = @token.user
    with_locale_for(user) do
      subject = t(:mail_subject_lost_password, value: Setting.app_title)
      mail to: user.mail, subject: subject
    end
  end

  def copy_project_failed(user, source_project, target_project_name, errors)
    @source_project = source_project
    @target_project_name = target_project_name
    @errors = errors

    open_project_headers 'Source-Project' => source_project.identifier,
                         'Author'         => user.login

    message_id source_project, user

    with_locale_for(user) do
      subject = I18n.t('copy_project.failed', source_project_name: source_project.name)

      mail to: user.mail, subject: subject
    end
  end

  def copy_project_succeeded(user, source_project, target_project, errors)
    @source_project = source_project
    @target_project = target_project
    @errors = errors

    open_project_headers 'Source-Project' => source_project.identifier,
                         'Target-Project' => target_project.identifier,
                         'Author'         => user.login

    message_id target_project, user

    with_locale_for(user) do
      subject = I18n.t('copy_project.succeeded', target_project_name: target_project.name)

      mail to: user.mail, subject: subject
    end
  end

  def news_added(user, news, author)
    @news = news

    open_project_headers 'Type'    => 'News'
    open_project_headers 'Project' => @news.project.identifier if @news.project

    message_id @news, user

    with_locale_for(user) do
      subject = "#{News.model_name.human}: #{@news.title}"
      subject = "[#{@news.project.name}] #{subject}" if @news.project
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def user_signed_up(token)
    return unless token.user

    @token = token
    @activation_url = url_for(controller: '/account',
                              action:     :activate,
                              token:      @token.value)

    open_project_headers 'Type' => 'Account'

    user = token.user
    with_locale_for(user) do
      subject = t(:mail_subject_register, value: Setting.app_title)
      mail to: user.mail, subject: subject
    end
  end

  def news_comment_added(user, comment, author)
    @comment = comment
    @news    = @comment.commented

    open_project_headers 'Project' => @news.project.identifier if @news.project

    message_id @comment, user
    references @news, user

    with_locale_for(user) do
      subject = "#{News.model_name.human}: #{@news.title}"
      subject = "Re: [#{@news.project.name}] #{subject}" if @news.project
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def wiki_content_added(user, wiki_content, author)
    @wiki_content = wiki_content

    open_project_headers 'Project'      => @wiki_content.project.identifier,
                         'Wiki-Page-Id' => @wiki_content.page.id,
                         'Type'         => 'Wiki'

    message_id @wiki_content, user

    with_locale_for(user) do
      subject = "[#{@wiki_content.project.name}] #{t(:mail_subject_wiki_content_added, id: @wiki_content.page.title)}"
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def wiki_content_updated(user, wiki_content, author)
    @wiki_content  = wiki_content
    @wiki_diff_url = url_for(controller: '/wiki',
                             action:     :diff,
                             project_id: wiki_content.project,
                             id:         wiki_content.page.slug,
                             # using wiki_content.version + 1 because at this point the journal is not saved yet
                             version:    wiki_content.version + 1)

    open_project_headers 'Project'      => @wiki_content.project.identifier,
                         'Wiki-Page-Id' => @wiki_content.page.id,
                         'Type'         => 'Wiki'

    message_id @wiki_content, user

    with_locale_for(user) do
      subject = "[#{@wiki_content.project.name}] #{t(:mail_subject_wiki_content_updated, id: @wiki_content.page.title)}"
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def message_posted(user, message, author)
    @message     = message
    @message_url = topic_url(@message.root, r: @message.id, anchor: "message-#{@message.id}")

    open_project_headers 'Project'      => @message.project.identifier,
                         'Wiki-Page-Id' => @message.parent_id || @message.id,
                         'Type'         => 'Forum'

    message_id @message, user
    references @message.parent, user if @message.parent

    with_locale_for(user) do
      subject = "[#{@message.board.project.name} - #{@message.board.name} - msg#{@message.root.id}] #{@message.subject}"
      mail_for_author author, to: user.mail, subject: subject
    end
  end

#ban (
  def message_changed(user, message, author, timenow)
    @timenow = timenow
    @message     = message
    @message_url = topic_url(@message.root, r: @message.id, anchor: "message-#{@message.id}")

    open_project_headers 'Project'      => @message.project.identifier,
                         'Wiki-Page-Id' => @message.parent_id || @message.id,
                         'Type'         => 'Forum'

    message_id @message, user
    references @message.parent, user if @message.parent

    with_locale_for(user) do
      subject = "[#{@message.board.project.name} - #{@message.board.name} - msg#{@message.root.id} - сообщение изменено] #{@message.subject}"
      mail_for_author author, to: user.mail, subject: subject
    end
  end

  def message_deleted(user, project_name, board_name, message_subject, author, timenow)
    @timenow = timenow
    @project_name = project_name
    @board_name = board_name
    @message_subject = message_subject

    with_locale_for(user) do
      subject = "[#{@project_name} - #{@board_name} - сообщение удалено] #{@message_subject}"
      mail_for_author author, to: user.mail, subject: subject
    end
  end
#)

  def account_activated(user)
    @user = user

    open_project_headers 'Type' => 'Account'

    with_locale_for(user) do
      subject = t(:mail_subject_register, value: Setting.app_title)
      mail to: user.mail, subject: subject
    end
  end

  def account_information(user, password)
    @user     = user
    @password = password

    open_project_headers 'Type' => 'Account'

    with_locale_for(user) do
      subject = t(:mail_subject_register, value: Setting.app_title)
      mail to: user.mail, subject: subject
    end
  end

  def account_activation_requested(admin, user)
    @user           = user
    @activation_url = url_for(controller: '/users',
                              action:     :index,
                              status:     'registered',
                              sort:       'created_at:desc')

    open_project_headers 'Type' => 'Account'

    with_locale_for(admin) do
      subject = t(:mail_subject_account_activation_request, value: Setting.app_title)
      mail to: admin.mail, subject: subject
    end
  end

  def reminder_mail(user, issues, days)
    @issues = issues
    @days   = days

    @assigned_issues_url = url_for(controller:     :work_packages,
                                   action:         :index,
                                   set_filter:     1,
                                   assigned_to_id: user.id,
                                   sort:           'due_date:asc')

    open_project_headers 'Type' => 'Issue'

    with_locale_for(user) do
      subject = t(:mail_subject_reminder, count: @issues.size, days: @days)
      mail to: user.mail, subject: subject
    end
  end

  ##
  # E-Mail to inform admin about a failed account activation due to the user limit.
  #
  # @param [String] user_email E-Mail of user who could not activate their account.
  # @param [User] admin Admin to be notified of this issue.
  def activation_limit_reached(user_email, admin)
    @email = user_email

    with_locale_for(admin) do
      mail to: admin.mail, subject: t("mail_user_activation_limit_reached.subject")
    end
  end

  private

  def subject_for_work_package(wp)
    "#{wp.project.name} - #{wp.status.name} #{wp.type.name} ##{wp.id}: #{wp.subject}"
  end

  # like #mail, but contains special author based filters
  # currently only:
  #  - remove_self_notifications
  # might be refactored at a later time to be as generic as Interceptors
  def mail_for_author(author, headers = {}, &block)
    message = mail headers, &block

    self.class.remove_self_notifications(message, author)

    message
  end

  def references(object, user)
    headers['References'] = "<#{self.class.generate_message_id(object, user)}>"
  end

  def set_work_package_headers(work_package)
    open_project_headers 'Project'        => work_package.project.identifier,
                         'Issue-Id'       => work_package.id,
                         'Issue-Author'   => work_package.author.login,
                         'Type'           => 'WorkPackage'

    if work_package.assigned_to
      open_project_headers 'Issue-Assignee' => work_package.assigned_to.login
    end
  end
end

##
# Interceptors
#
# These are registered in config/initializers/register_mail_interceptors.rb
#
# Unfortunately, this results in changes on the interceptor classes during development mode
# not being reflected until a server restart.

class DefaultHeadersInterceptor
  def self.delivering_email(mail)
    mail.headers(default_headers)
  end

  def self.default_headers
    {
      'X-Mailer'           => 'OpenProject',
      'X-OpenProject-Host' => Setting.host_name,
      'X-OpenProject-Site' => Setting.app_title,
      'Precedence'         => 'bulk',
      'Auto-Submitted'     => 'auto-generated'
    }
  end
end

class DoNotSendMailsWithoutReceiverInterceptor
  def self.delivering_email(mail)
    receivers = [mail.to, mail.cc, mail.bcc]
    # the above fields might be empty arrays (if entries have been removed
    # by another interceptor) or nil, therefore checking for blank?
    mail.perform_deliveries = false if receivers.all?(&:blank?)
  end
end

# helper object for `rake redmine:send_reminders`

class DueIssuesReminder
  def initialize(days = nil, project_id = nil, type_id = nil, user_ids = [])
    @days     = days ? days.to_i : 7
    @project  = Project.find_by(id: project_id)
    @type  = ::Type.find_by(id: type_id)
    @user_ids = user_ids
  end

  def remind_users
    s = ARCondition.new ["#{Status.table_name}.is_closed = ? AND #{WorkPackage.table_name}.due_date <= ?", false, @days.days.from_now.to_date]
    s << "#{WorkPackage.table_name}.assigned_to_id IS NOT NULL"
    s << ["#{WorkPackage.table_name}.assigned_to_id IN (?)", @user_ids] if @user_ids.any?
    s << "#{Project.table_name}.status = #{Project::STATUS_ACTIVE}"
    s << "#{WorkPackage.table_name}.project_id = #{@project.id}" if @project
    s << "#{WorkPackage.table_name}.type_id = #{@type.id}" if @type

    issues_by_assignee = WorkPackage.includes(:status, :assigned_to, :project, :type)
                         .where(s.conditions)
                         .references(:projects)
                         .group_by(&:assigned_to)
    issues_by_assignee.each do |assignee, issues|
      UserMailer.reminder_mail(assignee, issues, @days).deliver_now if assignee && assignee.active?
    end
  end
end
