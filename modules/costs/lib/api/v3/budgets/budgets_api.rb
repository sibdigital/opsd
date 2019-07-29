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
            all_budgets = AllBudgetsHelper.all_buget current_user
            ab = AllBudget.new all_budgets[:spent], all_budgets[:ne_ispoln], all_budgets[:ostatok]
            AllBudgetRepresenter.new(ab, current_user: current_user)
          end
        end
        # -tan
      end

      #+tan
      class AllBudget

        def initialize(ispoln = 0, ne_ispoln = 0, ostatok = 0)
          @ispoln = ispoln
          @ne_ispoln = ne_ispoln
          @ostatok = ostatok
        end

        def ispoln
          @ispoln
        end

        def ne_ispoln
          @ne_ispoln
        end

        def ostatok
          @ostatok
        end

      end
      # -tan
    end
  end
end
