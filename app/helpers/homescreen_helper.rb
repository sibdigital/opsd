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

module HomescreenHelper
  ##
  # Homescreen name
  def organization_name
    Setting.app_title || Setting.software_name
  end

  ##
  # Homescreen organization icon
  def organization_icon
    op_icon('icon-context icon-enterprise')
  end

  ##
  # Returns the user avatar or a default image
  def homescreen_user_avatar
    op_icon('icon-context icon-user')
  end

  ##
  # Render a static link defined in OpenProject::Static::Links
  def static_link_to(key)
    link = OpenProject::Static::Links.links[key]
    label = I18n.t(link[:label])

    link_to label,
            link[:href],
            title: label,
            target: '_blank'
  end

  ##
  # Determine whether we should render the links on homescreen?
  def show_homescreen_links?
    EnterpriseToken.show_banners? || OpenProject::Configuration.show_community_links?
  end

  ##
  # Determine whether we should render the onboarding modal
  def show_onboarding_modal?
    OpenProject::Configuration.onboarding_enabled? && params[:first_time_user]
  end

  # bbm(
  # Функция заполнения значений долей диаграммы Показатели на рабочем столе
  # В случае имзенения алгоритма среднего процента исполнения переделать функцию completed_percent_sd в project.rb
  def rabocii_stol_pokazateli_data
    ispolneno = 0 # Порядок важен
    ne_ispolneno = 0
    v_rabote = 0
    Project.all.map(&:completed_percent_sd).each do |completed_percent|
      case completed_percent
      when 0
        ne_ispolneno += 1
      when 100
        ispolneno += 1
      else
        v_rabote += 1
      end
    end
    result = Hash.new
    result['data'] = []
    # Порядок важен
    result['data'] << ispolneno
    result['data'] << ne_ispolneno
    result['data'] << v_rabote
    result['label'] = 'Процент исполнения'
    result.to_json
  end

  # Функция заполнения значений долей диаграммы KT на рабочем столе
  def rabocii_stol_kt_data
    ispolneno = 0 # Порядок важен
    ne_ispolneno = 0
    v_rabote = 0
    riski = 0
    WorkPackage
      .where(type_id: 2, plan_type: :execution)
      .map { |f| [f.status.is_closed, f.due_date] }
      .each do |wp|
      # TODO: Доделать как разбить WP по группам согласно ТЗ
      if wp[0] = true
        ispolneno += 1
      elsif wp[1] > Time.zone.now.beginning_of_day
        v_rabote += 1
      else
        ne_ispolneno += 1
    end
    end
    result = Hash.new
    result['data'] = []
    # Порядок важен
    result['data'] << ispolneno
    result['data'] << ne_ispolneno
    result['data'] << v_rabote
    result['data'] << riski
    result['label'] = 'КТ'
    result.to_json
  end

  # Функция заполнения значений долей диаграммы Бюджет на рабочем столе
  def rabocii_stol_budjet_data
    ispolneno = 0 # Порядок важен
    ne_ispolneno = 0
    ostatok = 0
    # TODO: Написать функцию выбоки исполнения бюджета исходя из бюджета мероприятий - нет четкого ТЗ
    result = Hash.new
    result['data'] = []
    # Порядок важен
    result['data'] << ispolneno
    result['data'] << ne_ispolneno
    result['data'] << ostatok
    result['label'] = 'Бюджет'
    result.to_json
  end

  # Функция заполнения данных для синей таблицы в Контрольных точках
  def kontrolnie_tochki_white_table_data
    # TODO: Переделать на нунжное поведение согласно ТЗ - в нем нет четких указаний
    result = Hash.new
    project = Project.find(1)
    result['project'] = project
    result['kurator'] = []
    User.all.each do |user|
      user.roles(project).map do |role|
        if role == Role.find_by(name: I18n.t(:default_role_project_curator))
          result['kurator'] << user
        end
      end
    end
    result
  end

  # Функция заполнения данных для синей таблицы в Контрольных точках
  def kontrolnie_tochki_blue_table_data(project)
    # TODO: Расширить список атритубов WP показателями факт исполнения и статуса исполнения согласно ТЗ - в нем нет четких указаний
    WorkPackage
      .where(project_id: project.id)
  end

  # unused
  def diagram_by_date_amount(project)
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
                          .where(statuses: { is_closed: true }, project_id: project.id)
                          .count
      when 1
        amount['data'] << WorkPackage
                          .joins(:status)
                          .where(statuses: { is_closed: false }, project_id: project.id)
                          .where('due_date < ?', Time.zone.now.beginning_of_day)
                          .count
      when 2
        amount['data'] << WorkPackage
                          .joins(:status)
                          .where(statuses: { is_closed: false }, project_id: project.id)
                          .where('due_date = ? or due_date = ?', Time.zone.now.beginning_of_day, (Time.zone.now + 1).beginning_of_day)
                          .count
      when 3
        amount['data'] << WorkPackage
                          .joins(:status)
                          .where(statuses: { is_closed: false }, project_id: project.id)
                          .where('due_date > ? and due_date <= ?', (Time.zone.now + 1).beginning_of_day, (Time.zone.now + 14).beginning_of_day)
                          .count
      when 4
        amount['data'] << WorkPackage
                          .joins(:status)
                          .where(statuses: { is_closed: false }, project_id: project.id)
                          .where('due_date > ?', (Time.zone.now + 14).beginning_of_day)
                          .count
      end
      amount['label'] = period
      amounts << amount
    end
    amounts.to_json
  end
  # )
end
