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

class AdminController < ApplicationController
  layout 'admin'

  before_action :require_admin

  menu_item :plugins, only: [:plugins]
  menu_item :info, only: [:info]

  def index
    redirect_to controller: 'users', action: 'index'
  end

  def projects
    redirect_to controller: 'projects', action: 'index'
  end

  def plugins
    @plugins = Redmine::Plugin.all.sort
  end

  def test_email
    raise_delivery_errors = ActionMailer::Base.raise_delivery_errors
    # Force ActionMailer to raise delivery errors so we can catch it
    ActionMailer::Base.raise_delivery_errors = true
    begin
      @test = UserMailer.test_mail(User.current).deliver_now
      flash[:notice] = I18n.t(:notice_email_sent, value: User.current.mail)
    rescue => e
      flash[:error] = I18n.t(:notice_email_error, value: Redmine::CodesetUtil.replace_invalid_utf8(e.message.dup))
    end
    ActionMailer::Base.raise_delivery_errors = raise_delivery_errors
    redirect_to controller: '/settings', action: 'edit', tab: 'notifications'
  end
  #knm +
  # nse for http://localhost:3000/admin/send_email_assignee_report?
  def send_email_assignee_report
    workPackage = WorkPackage.find(params["workPackageId"])
    unless workPackage.assigned_to_id.nil?
      @assigneee = User.find(workPackage.assigned_to_id)
      @term_date = workPackage.due_date #ban
      @project_name = Project.find_by(id: workPackage.project_id).name #ban
      UserMailer.work_package_report_notify_assignee(@assigneee,@term_date.to_s,workPackage,@project_name).deliver_now #ban
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
    redirect_to project_work_package_path(Project.find_by(id: workPackage.project_id), workPackage)
  end
  #knm-
  #knm+
  def create_board_from_wp
    redirect_to new_project_board_path(@project)
  end
  # -

 # iag(
  def send_email_assignee_from_task
    raise_delivery_errors = ActionMailer::Base.raise_delivery_errors
    # Force ActionMailer to raise delivery errors so we can catch it
    ActionMailer::Base.raise_delivery_errors = true
    begin
      workPackageId = params[:workPackageId];

      workPackage = WorkPackage.find(workPackageId);

      assigneee = User.find(workPackage.assigned_to_id);

      term_date = workPackage.due_date #ban

      project_name = Project.find_by(id: workPackage.project_id).name #ban

      UserMailer.work_package_notify_assignee(assigneee,term_date.to_s,workPackage,project_name).deliver_later #ban
    rescue => e
      flash[:error] = I18n.t(:notice_email_error, value: Redmine::CodesetUtil.replace_invalid_utf8(e.message.dup))
    end
    ActionMailer::Base.raise_delivery_errors = raise_delivery_errors
  end
 # )

 # iag(
 #  def send_email_from_forum
 #    raise_delivery_errors = ActionMailer::Base.raise_delivery_errors
 #    # Force ActionMailer to raise delivery errors so we can catch it
 #    ActionMailer::Base.raise_delivery_errors = true
 #    begin
 #      UserMailer.notify_forum_notify_assignee(params[:mail]).deliver_now
 #    rescue => e
 #      flash[:error] = I18n.t(:notice_email_error, value: Redmine::CodesetUtil.replace_invalid_utf8(e.message.dup))
 #    end
 #    ActionMailer::Base.raise_delivery_errors = raise_delivery_errors
 #
 #  end
 # )

  def force_user_language
    available_languages = Setting.find_by(name: 'available_languages').value
    User.where(['language not in (?)', available_languages]).each do |u|
      u.language = Setting.default_language
      u.save
    end

    redirect_to :back
  end

  def info
    @db_adapter_name = ActiveRecord::Base.connection.adapter_name
    repository_writable = File.writable?(OpenProject::Configuration.attachments_storage_path)
    @checklist = [
      [:text_default_administrator_account_changed, User.default_admin_account_changed?],
      [:text_file_repository_writable, repository_writable],
      [:text_database_allows_tsv, OpenProject::Database.allows_tsv?]
    ]

    if OpenProject::Database.allows_tsv?
      @checklist += plaintext_extraction_checks
    end

    @storage_information = OpenProject::Storage.mount_information
  end

  def default_breadcrumb
    case params[:action]
    when 'plugins'
      l(:label_plugins)
    when 'info'
      l(:label_information)
    end
  end

  def show_local_breadcrumb
    true
  end

  private

  def plaintext_extraction_checks
    [
      [:'extraction.available.pdftotext', Plaintext::PdfHandler.available?],
      [:'extraction.available.unrtf',     Plaintext::RtfHandler.available?],
      [:'extraction.available.catdoc',    Plaintext::DocHandler.available?],
      [:'extraction.available.xls2csv',   Plaintext::XlsHandler.available?],
      [:'extraction.available.catppt',    Plaintext::PptHandler.available?],
      [:'extraction.available.tesseract', Plaintext::ImageHandler.available?]
    ]
  end
end
