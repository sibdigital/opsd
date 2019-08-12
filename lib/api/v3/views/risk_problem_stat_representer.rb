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
      class RiskProblemStatRepresenter < ::API::Decorators::Single
        #include ::API::Caching::CachedRepresenter

        self_link path: :problem,
                  title_getter: ->(*) { represented.id }

        property :id
        property :work_package_id
        property :importance_id, render_nil: true
        property :importance, render_nil: true
        property :type, render_nil: true

        property :project,
                 exec_context: :decorator,
                 getter: ->(*) { represented.work_package_problem.project },
                 render_nil: true

        property :solution_date,
                 exec_context: :decorator,
                 getter: ->(*) { represented.work_package_problem.solution_date },
                 render_nil: true

        property :risk_or_problem,
                 exec_context: :decorator,
                 getter: ->(*) { represented.work_package_problem.risk ? represented.work_package_problem.risk.name : represented.work_package_problem.description },
                 render_nil: true

        property :user_creator,
                 exec_context: :decorator,
                 getter: ->(*) { represented.work_package_problem.user_creator },
                 render_nil: true

        property :user_source,
                 exec_context: :decorator,
                 getter: ->(*) { represented.work_package_problem.user_source },
                 render_nil: true

        def _type
          'RiskProblemStat'
        end
      end
    end
  end
end
