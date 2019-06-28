#-- copyright
# OpenProject My Project Page Plugin
#
# Copyright (C) 2011-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
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
# See doc/COPYRIGHT.md for more details.
#++
require 'json'

module MyProjectsWorkPackagesHelper
  include WorkPackagesFilterHelper

  def types
    @types ||= project.rolled_up_types
  end

  #bbm(
  def work_packages_by_status_amount
    @statuses ||= Status.all.map(&:name)
    amounts = []
    for status in @statuses do
      amount = Hash.new
      amount['data'] = []
      amount['data'] << WorkPackage
        .joins(:status)
        .where(statuses: { name: status }, project_id: @project.id)
        .count
      amount['label'] = status
      amounts << amount
    end
    amounts.to_json
  end

  def work_packages_by_date_amount
    periods = [I18n.t('activities.label_performed'),
               I18n.t('activities.label_expired'),
               I18n.t('activities.label_urgently'),
               I18n.t('activities.label_soon'),
               I18n.t('activities.label_inwork')]
    amounts = []
    periods.each_with_index do |period, index|
      amount = Hash.new
      amount['data'] = []
      case index
      when 0
        amount['data'] << WorkPackage
                            .joins(:status)
                            .where(statuses: { is_closed: true }, project_id: @project.id)
                            .count
      when 1
        amount['data'] << WorkPackage
                            .joins(:status)
                            .where(statuses: { is_closed: false }, project_id: @project.id)
                            .where('due_date < ?', Time.zone.now.beginning_of_day)
                            .count
      when 2
        amount['data'] << WorkPackage
                            .joins(:status)
                            .where(statuses: { is_closed: false }, project_id: @project.id)
                            .where('due_date = ? or due_date = ?', Time.zone.now.beginning_of_day, (Time.zone.now+1).beginning_of_day)
                            .count
      when 3
        amount['data'] << WorkPackage
                            .joins(:status)
                            .where(statuses: { is_closed: false }, project_id: @project.id)
                            .where('due_date > ? and due_date <= ?', (Time.zone.now+1).beginning_of_day, (Time.zone.now + 14).beginning_of_day)
                            .count
      when 4
        amount['data'] << WorkPackage
                            .joins(:status)
                            .where(statuses: { is_closed: false }, project_id: @project.id)
                            .where('due_date > ?', (Time.zone.now + 14).beginning_of_day)
                            .count
      end
      amount['label'] = period
      amounts << amount
    end
    amounts.to_json
  end
  #)

  def subproject_condition
    @subproject_condition ||= project.project_condition(Setting.display_subprojects_work_packages?)
  end

  def open_work_packages_by_type
    @open_work_packages_by_tracker ||= work_packages_by_type
                                       .where(statuses: { is_closed: false })
                                       .count
  end

  def total_work_packages_by_type
    @total_work_packages_by_tracker ||= work_packages_by_type.count
  end

  def work_packages_by_type
    WorkPackage
      .visible
      .joins(:project)
      .group(:type)
      .includes([:project, :status, :type])
      .references(:projects)
      .where(subproject_condition)
  end

  def assigned_work_packages
    @assigned_issues ||= WorkPackage
                         .visible
                         .open
                         .where(assigned_to: User.current.id)
                         .limit(10)
                         .includes([:status, :project, :type, :priority])
                         .order("#{IssuePriority.table_name}.position DESC,
                                 #{WorkPackage.table_name}.updated_on DESC")
  end
end
