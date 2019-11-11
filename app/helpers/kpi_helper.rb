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

module KpiHelper
  include ApplicationHelper

  # 7.	Количество внесенных в реестр рисков
  # Учитывать количество рисков в реестре рисков для ролей: куратор проекта, руководитель проекта, администратор проекта,
  # координатор от Проектного офиса
  # 5-8 - 10%
  # 8-15 – 15%
  def calc_kpi_saved_risks(user)
    kpi = KeyPerformanceIndicator.find(:name, I18n.t(:default_kpi_saved_risks))
    members = members_by_key_performance_indicator_cases(user.id, kpi.id)
    #roles = Role.where(name: [I18n.t(:default_role_project_curator), I18n.t(:default_role_project_head),
    #                  I18n.t(:default_role_project_admin), I18n.t(:default_role_project_office_coordinator)]).to_a
    sql = <<-SQL
          select count(id) as cnt from risks as r
          where r.project_id in (?)
    SQL
    result = ActiveRecord::Base.connection.execute(sql, members.map {|m| m.project_id})
    val_result = result.present? ? result[0]['cnt'] : 0

    percent = percent_by_val(val_result, kpi.id)
  end

  private

  def members_by_key_performance_indicator_cases(user_id, kpi_id)
    sql = <<-SQL
      select distinct m.role_id, project_id from member_roles as m
      inner join (
                   select id, project_id
      from members as mb
      where mb.user_id = ?
      ) as mb
      on m.member_id = mb.id
      inner join (
                   select *
                     from key_performance_indicator_cases as k
      where k.key_performance_indicator_id = ?
      ) as kpi
      on m.role_id = kpi.role_id
    SQL
    MemberRole.where(sql, user_id, kpi_id)
  end

  def percent_by_val(val, kpi_id)
    sql = <<-SQL
      select max(percent) as percent from key_performance_indicator_cases as kc
      where kc.key_performance_indicator_id = ? and ? >= kc.min_value and ? <= kc.max_value
    SQL

    result = ActiveRecord::Base.connection.execute(sql, kpi_id, val, val)
    val_result = result.present? ? result[0]['percent'] : 0
  end
end
