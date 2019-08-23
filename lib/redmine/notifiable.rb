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

module Redmine
  class Notifiable < Struct.new(:name, :parent)
    def to_s
      name
    end

    # TODO: Plugin API for adding a new notification?
    def self.all
      notifications = []
      notifications << Notifiable.new('work_package_added')
      notifications << Notifiable.new('work_package_updated')
      notifications << Notifiable.new('work_package_note_added', 'work_package_updated')
      notifications << Notifiable.new('status_updated', 'work_package_updated')
      notifications << Notifiable.new('work_package_priority_updated', 'work_package_updated')
      notifications << Notifiable.new('news_added')
      notifications << Notifiable.new('news_changed')
      notifications << Notifiable.new('news_deleted')
      notifications << Notifiable.new('news_comment_added')
      notifications << Notifiable.new('file_added')
      notifications << Notifiable.new('message_posted')
      notifications << Notifiable.new('message_changed') #ban
      notifications << Notifiable.new('message_deleted') #ban
      notifications << Notifiable.new('wiki_content_added')
      notifications << Notifiable.new('wiki_content_updated')
      notifications << Notifiable.new('cost_object_added') #ban
      notifications << Notifiable.new('member_added') #ban
      notifications << Notifiable.new('member_deleted') #ban
      notifications << Notifiable.new('board_added') #ban
      notifications << Notifiable.new('board_changed') #ban
      notifications << Notifiable.new('board_moved') #ban
      notifications << Notifiable.new('board_deleted') #ban
      notifications << Notifiable.new('deadline_of_work_package_is_approaching') #ban
      notifications << Notifiable.new('deadline_of_work_package') #ban
      notifications << Notifiable.new('project_created') #ban
      notifications << Notifiable.new('project_changed') #ban
      notifications << Notifiable.new('project_deleted') #ban
      notifications << Notifiable.new('deadline_of_project_is_approaching') #ban
      notifications << Notifiable.new('deadline_of_project') #ban
      notifications
    end
  end
end
