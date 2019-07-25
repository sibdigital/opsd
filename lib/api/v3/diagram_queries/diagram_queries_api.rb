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

require 'api/v3/diagram_queries/diagram_query_representer'

module API
  module V3
    module DiagramQueries
      class DiagramQueriesAPI < ::API::OpenProjectAPI
        resources :diagram_queries do
          before do
            authorize(:view_work_packages, global: true)

            @diagram_queries = DiagramQuery.all
          end

          get do
            DiagramQueryCollectionRepresenter.new(@diagram_queries,
                                              api_v3_paths.diagram_queries,
                                              current_user: current_user)
          end

          post do
            diagram_query = DiagramQuery.new
            diagram_query.name = 'name'
            diagram_query.params = params
            diagram_query.save
          end

          route_param :id do
            before do
              @diagram_query = DiagramQuery.find(params[:id])
            end

            get do
              DiagramQueryRepresenter.new(@diagram_query, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
