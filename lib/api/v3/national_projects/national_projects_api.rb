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

require 'api/v3/national_projects/national_project_representer'

module API
  module V3
    module NationalProjects
      class NationalProjectsAPI < ::API::OpenProjectAPI
        resources :national_projects do
          get do
            @national_projects = NationalProject.all
            NationalProjectCollectionRepresenter.new(@national_projects,
                                                     api_v3_paths.national_projects,
                                                     current_user: current_user)
          end

          params do
            requires :id, desc: 'National Project id'
          end

          route_param :id do
            before do
              @national_project = NationalProject.find(params[:id])
            end

            get do
              NationalProjectRepresenter.new(@national_project, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
