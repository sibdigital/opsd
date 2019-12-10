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

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Protocols
      class ProtocolRepresenter < ::API::Decorators::Single
        #include ::API::Caching::CachedRepresenter

        self_link path: :protocol,
                  title_getter: ->(*) { represented.text }

        property :id, render_nil: true

        property :text, render_nil: true
        property :user, render_nil: true
        property :due_date, render_nil: true
        property :days_to_due,
                 exec_context: :decorator,
                 getter: ->(*){
                   days_count = represented.due_date - Date.current
                   days_count.to_i
                 },
                 render_nil: true
        property :completed, render_nil: true

        property :project,
                 exec_context: :decorator,
                 getter: ->(*) { represented.meeting.project },
                 #getter: ->(*) { 'Неизвестно' },
                 render_nil: true

        property :meeting_id,
                 exec_context: :decorator,
                 getter: ->(*) { represented.meeting.id },
                 render_nil: true

        def _type
          'Protocol'
        end
      end
    end
  end
end
