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

require 'open_project/static/homescreen'
require 'open_project/static/links'

OpenProject::Static::Homescreen.manage :blocks do |blocks|
  blocks.push(
    {
      partial: 'welcome',
      if: Proc.new { Setting.welcome_on_homescreen? && Setting.welcome_text.present? }
    },
    {
      partial: 'projects'
    },
    #zbd(
    {
      partial: 'work_packages',
      if: Proc.new { User.current.logged? }
    },
    # )
    {
      partial: 'users',
      if: Proc.new { User.current.admin? }
    },
    {
      partial: 'my_account',
      if: Proc.new { User.current.logged? }
    },
    #bbm(
    {
      partial: 'overview_diagram',
      if: Proc.new { User.current.logged? }
    },

    {
      partial: 'diagram_done_ratio',
      if: Proc.new { User.current.logged? }
    },

    {
      partial: 'diagram_date_ratio_as_rukovoditel',
      if: Proc.new { User.current.logged? && !@rukovoditel_proekta_dlya_etih_proektov.empty? }
    },

    {
      partial: 'diagram_date_ratio_as_kurator',
      if: Proc.new { User.current.logged? && !@kurator_dlya_etih_proektov.empty? }
    },

    {
      partial: 'diagram_date_ratio_as_ruk_proekt_ofisa',
      if: Proc.new { User.current.logged? && !@ruk_proekt_ofisa_dlya_etih_proektov.empty? }
    },

    {
      partial: 'diagram_date_ratio_as_koordinator',
      if: Proc.new { User.current.logged? && !@koordinator_dlya_etih_proektov.empty? }
    },
    { #+tan
      partial: 'statistik',
      if: Proc.new { User.current.logged? && (User.current.admin? || @koordinator_dlya_etih_proektov.empty? || !@ruk_proekt_ofisa_dlya_etih_proektov.empty? || !@kurator_dlya_etih_proektov.empty? || !@rukovoditel_proekta_dlya_etih_proektov.empty?)}
    },
    # )
    {
      partial: 'news',
      if: Proc.new { !@news.empty? }
    },
    # {
    #   partial: 'community',
    #   if: Proc.new { EnterpriseToken.show_banners? || OpenProject::Configuration.show_community_links? }
    # },
    {
      partial: 'administration',
      if: Proc.new { User.current.admin? }
    }#,
    # {
    #   partial: 'upsale',
    #   if: Proc.new { EnterpriseToken.show_banners? }
    # }
  )
end

OpenProject::Static::Homescreen.manage :links do |links|
  link_hash = OpenProject::Static::Links.links

  links.push(
    {
      label: :user_guides,
      icon: 'icon-context icon-rename',
      url: link_hash[:user_guides][:href]
    },
    {
      label: :glossary,
      icon: 'icon-context icon-glossar',
      url: link_hash[:glossary][:href]
    },
    {
      label: :shortcuts,
      icon: 'icon-context icon-shortcuts',
      url: link_hash[:shortcuts][:href]
    },
    {
      label: :boards,
      icon: 'icon-context icon-forums',
      url: link_hash[:boards][:href]
    }
  )

  if impressum_link = link_hash[:impressum]
    links.push({
      label: impressum_link[:label],
      url: impressum_link[:href],
      icon: 'icon-context icon-info1'
    })
  end
end
