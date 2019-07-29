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

  before_action :set_current_user

  include DateAndTime::Calculations

  def vkladka1
    @tab = :vkladka1
    render :index, locals: { menu_name: :dashboard_menu }
  end

  def vkladka2
    @tab = :vkladka2
    render :index
  end

  def index
    if @tab.blank?
      redirect_to edit_tab_homescreen1_path
    end
    # Отображать незарегестрированным пользователям
  end

  def robots
    @projects = Project.active.public_projects
  end

  def set_current_user
    @user = current_user
  end
end
