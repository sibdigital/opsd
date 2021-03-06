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

module API
  module V3
    module Queries
      class QueriesByProjectAPI < ::API::OpenProjectAPI
        namespace :queries do
          helpers ::API::V3::Queries::Helpers::QueryRepresenterResponse

          before do
            authorize(:view_work_packages, context: @project, user: current_user)
          end

          mount API::V3::Queries::Schemas::QueryProjectFilterInstanceSchemaAPI
          mount API::V3::Queries::Schemas::QueryProjectSchemaAPI

          namespace :default do
            get do
              query = Query.new_default(name: 'default',
                                        user: current_user,
                                        project: @project)

              #+tan tmd
              # if !current_user.has_priveleged?(@project) && !current_user.admin?
              #   org = current_user.organization
              #   childs = org != nil ? org.childs().map {|c| c.id.to_i} : [0]
              #   query.add_filter('organization_id', '=', childs)
              #-
              # end

              query_representer_response(query, params)
            end
          end
        end
      end
    end
  end
end
