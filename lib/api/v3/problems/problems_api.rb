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
        helpers ::API::V3::Utilities::RoleHelper

        resources :problems do
          get do
=begin
tempproblems = WorkPackageProblem
  .joins(:work_package)
  .all
tempproblems = tempproblems.where(status: params['status']) if params['status'].present?
if params['raion'].present?
  tempproblems = tempproblems.where(work_packages: {raion_id: params['raion']})
end
tempproblems = if params['project'].present?
              tempproblems.where(project_id: params['project'])
            else
              projects = current_user.projects.map{|p| p.id}
              if projects.nil? || projects.empty?
                tempproblems.where(project_id: nil)#Зачем выполнять лишние запросы
              else
                tempproblems.where('work_package_problems.project_id in (' + projects.join(',') + ')')
              end
            end
tempproblems = tempproblems.where(work_packages: {organization_id: params['organization']}) if params['organization'].present?
=end



  user_projects = [0]
  if params['project'].present? && params['raion'] != '0'
    user_projects = [params['project']]
  else
    user_projects = current_user.visible_projects.map(&:id)
  end

  problems = WorkPackageProblem.where('work_package_problems.project_id in (' + user_projects.join(',') + ')')

  if params['raion'].present? && params['raion'] != '0'
    problems = problems.joins(:work_package).where(work_packages: {raion_id: params['raion']})
  end
  if params['status'].present?
    problems = problems.where(status: params['status'])
  end
  if params['organization'].present?
    problems = problems.where({organization_id: params['organization']})
  end

=begin
            temparr = tempproblems - problems

            if(temparr.empty?)
              Rails.logger.info "PROBLEMS are identical"
            else
              Rails.logger.info "PROBLEMS NOT identical"
            end
=end


  offset = params['offset'] || "1"
  ProblemCollectionRepresenter.new(problems,
                                   api_v3_paths.problems,
                                   page: offset.to_i,
                                   per_page: 5,
                                   current_user: current_user)#Есть ограничение на количество проблем - per_page
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
