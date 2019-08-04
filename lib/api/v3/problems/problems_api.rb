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

require 'api/v3/problems/problem_representer'

module API
  module V3
    module Problems
      class ProblemsAPI < ::API::OpenProjectAPI
        resources :problems do
          get do
            @problems = if params['status'].present? and params['project'].present?
                          WorkPackageProblem.where(status: params['status'], project_id: params['project'])
                        elsif params['status'].present?
                          WorkPackageProblem.where(status: params['status'])
                        elsif params['project'].present?
                          WorkPackageProblem.where(project_id: params['project'])
                        else
                          WorkPackageProblem.all
                        end
            ProblemCollectionRepresenter.new(@problems,
                                             api_v3_paths.problems,
                                             page: 1,
                                             per_page: 20,
                                             current_user: current_user)
          end

          params do
            requires :id, desc: 'Problem id'
          end

          route_param :id do
            before do
              @problem = WorkPackageProblem.find(params[:id])
            end

            get do
              ProblemRepresenter.new(@problem, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
