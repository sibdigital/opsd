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

class HomescreenController < ApplicationController
  skip_before_action :check_if_login_required, only: [:robots]

  layout 'no_menu'

  before_action :set_current_user

  include DateAndTime::Calculations

  def index
    @newest_projects = Project.visible.newest.take(3)
    @newest_users = User.active.newest.take(3)
    @news = News.latest(count: 3)
    @announcement = Announcement.active_and_current

    #zbd(
    @remaining_days = Setting.remaining_count_days.to_i
    now = Date.today + 14

    if !@user.nil?
      @works = []
      if (MemberRole.joins("INNER JOIN members ON member_roles.member_id=members.id INNER JOIN roles ON member_roles.role_id=roles.id")
           .where("position in (?) and user_id = ?", [6, 7, 9, 10, 11, 12, 14, 15, 16], @user.id)
           .count > 0) or (@user.admin)
        @works = WorkPackage.visible(@user).where("due_date >= :d1 and due_date <= :d2 and done_ratio<100", {d1: Date.today, d2: now})
      else
        @works = WorkPackage.with_assigned(@user).where("due_date >= :d1 and due_date <= :d2 and done_ratio<100", {d1: Date.today, d2: now}) #{due_date: (Date.today)..now})
      end
    end
    # )

    @homescreen = OpenProject::Static::Homescreen

    #bbm(
    @rukovoditel_proekta_dlya_etih_proektov = []
    @kurator_dlya_etih_proektov = []
    @ruk_proekt_ofisa_dlya_etih_proektov = []
    @koordinator_dlya_etih_proektov = []
    @all = Project.all
    Project.all.map do |project|
      current_user.roles(project).map do |role|
        if role == Role.find_by(name: I18n.t(:default_role_project_head))
          @rukovoditel_proekta_dlya_etih_proektov << project
        end
        if role == Role.find_by(name: I18n.t(:default_role_project_curator))
          @kurator_dlya_etih_proektov << project
        end
        if role == Role.find_by(name: I18n.t(:default_role_project_office_manager))
          @ruk_proekt_ofisa_dlya_etih_proektov << project
        end
        if role == Role.find_by(name: I18n.t(:default_role_project_office_coordinator))
          @koordinator_dlya_etih_proektov << project
        end
      end
    end
    # )
    #
    # +tan 2019.07.09
    sql = "select u.*, wu.done_ratio, wu.wp_count
          from users as u
          left join(
            select w.assigned_to_id as user_id, avg(done_ratio) as done_ratio, count(id) as wp_count
            from work_packages as w
            group by w.assigned_to_id
          ) as wu
          on u.id = wu.user_id
          where u.status > 0"

    @users_stat = ActiveRecord::Base.connection.execute(sql)

    sql = "select p.name as project_name, count(d.id) as count_doc
          from projects as p
          left join documents as d
          on p.id = d.project_id
          group by p.name"

    @docs_stat = ActiveRecord::Base.connection.execute(sql)
    # -tan
  end

  def robots
    @projects = Project.active.public_projects
  end

  def set_current_user
    @user = current_user
  end
end
