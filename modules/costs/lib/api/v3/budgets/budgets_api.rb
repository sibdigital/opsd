#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
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
# See doc/COPYRIGHT.rdoc for more details.
#++

module API
  module V3
    module Budgets
      class BudgetsAPI < ::API::OpenProjectAPI
        helpers ::API::Utilities::ParamsHelper

        #include AllBudgetsHelper
        resources :budgets do
          route_param :id do
            before do
              @budget = CostObject.find(params[:id])

              authorize_any([:view_work_packages, :view_budgets], projects: @budget.project)
            end

            get do
              BudgetRepresenter.new(@budget, current_user: current_user)
            end

            mount ::API::V3::Attachments::AttachmentsByBudgetAPI
          end
        end

        #+tan
        resources :summary_budgets do
          before do
            authorize_any([:view_work_packages, :view_budgets], global: true)
          end

          get :all do
            AllBudgetsHelper.all_buget current_user
          end

          get :all_user do
            AllBudgetsHelper.user_projects_budgets current_user
          end

          get :federal do
            AllBudgetsHelper.federal_budget current_user
          end

          get :regional do
            AllBudgetsHelper.regional_budget current_user
          end

          get :vnebudget do
            AllBudgetsHelper.vnebudget_budget current_user
          end

          get :budget do
            result = Hash.new
            result['_type'] = 'Collection'

            current_projects = []
            raion_id = params[:raion]
            if raion_id && raion_id != '0'
              rprojects = Raion.projects_by_id(raion_id, current_user.projects.map {|p| p.id})
              ids = [0]
              rprojects.each do |project|
                ids << project.id
              end
              ps = Project.where("id in (" + ids.join(",") + ")")
              ps = ps.limit(params[:pageSize]) if params[:pageSize].present?
              ps = ps.offset(to_i_or_nil(params[:offset])) if params[:offset].present?
              current_projects = AllBudgetsHelper.cost_by_projects ps
              result['total'] = ids.length
            else
              project_id = params[:project]
              if project_id && project_id != '0'
                user_project = current_user.projects.find(project_id)
                current_project = AllBudgetsHelper.cost_by_project user_project
                current_projects << current_project
              else
                user_projects = current_user.projects
                user_projects = user_projects.limit(params[:pageSize]) if params[:pageSize].present?
                user_projects = user_projects.offset(to_i_or_nil(params[:offset])) if params[:offset].present?
                current_projects = AllBudgetsHelper.cost_by_projects user_projects
              end
              result['total'] = current_user.projects.count
            end

            result['pageSize'] = params[:pageSize].present? ? to_i_or_nil(params[:pageSize]) : current_user.projects.count
            result['offset'] = params[:offset].present? ? to_i_or_nil(params[:offset]) : 1
            result['count'] = current_projects.count
            result['elements'] = current_projects
            result
            # Project.where(type: Project::TYPE_PROJECT).all.map do |p|
            #   AllBudgetsHelper.cost_by_project p
            # end
          end
        end
        # -tan
      end
    end
  end
end
