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
  include WorkPackages

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
      #@works = Project.visible.newest.joins(:work_packages).where({work_packages: {due_date: (Date.today)..now }}) #   do |prj|
      #@projects =
      #Project.visible.newest.find_each do |prj|

      @works = WorkPackage.where({due_date: (Date.today)..now, assigned_to: @user.id}) #.order("due_date DESC")

      #@memb = Member.visible(@user).joins(:member_roles).where({role_id: 35..37})
        #@roles = @user.roles_for_project(prj)
        #role_id: 39, 33, 35,36,37,30
        #@works.each do |work|
        #  work.prj = prj
        #end
      #end

      #.joins(:work_packages)
      #.where('work_packages.due_date < ?', now)
    end
    # )

    @homescreen = OpenProject::Static::Homescreen

  end

  def robots
    @projects = Project.active.public_projects
  end

  def set_current_user
    @user = current_user
  end

end
