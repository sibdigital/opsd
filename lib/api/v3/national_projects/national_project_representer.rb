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
    module NationalProjects
      class NationalProjectRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        self_link path: :national_project

        property :id, render_nil: true
        property :name, render_nil: true
        property :name,
                 exec_context: :decorator,
                 getter: ->(*) { represented.name[0..50]},
                 render_nil: true

        property :leader, render_nil: true
        property :leader_position, render_nil: true

        property :type, render_nil: true
        property :parent_id, render_nil: true

        property :curator, render_nil: true
        property :curator_position, render_nil: true

        property :start_date,
                 exec_context: :decorator,
                 getter: ->(*) { represented.start_date.nil? ? '' : datetime_formatter.format_datetime(represented.start_date) },
                 render_nil: true
        property :due_date,
                 exec_context: :decorator,
                 getter: ->(*) { represented.due_date.nil? ? '' : datetime_formatter.format_datetime(represented.due_date) },
                 render_nil: true

        property :description, render_nil: true

        def _type
          'NationalProject'
        end
      end
    end
  end
end
