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
    module Views
      class WorkPackageIspolnStatRepresenter < ::API::Decorators::Single
        #include ::API::Caching::CachedRepresenter

        property :id
        property :subject

        property :project,
                 exec_context: :decorator,
                 getter: ->(*) { represented.project },
                 render_nil: true

        property :assignee,
                 exec_context: :decorator,
                 getter: ->(*) { represented.assigned_to },
                 render_nil: true

        property :due_date, render_nil: true
        property :status_name, render_nil: true
        property :created_problem_count

        def _type
          'WorkPackageIspolnStat'
        end
      end
    end
  end
end
