#-- copyright
# OpenProject Costs Plugin
#
# Copyright (C) 2009 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

require 'csv'

module AllBudgetsHelper
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  def self.all_buget(user)
    cost_objects = CostObject.all
    total_budget = BigDecimal.new("0")
    labor_budget = BigDecimal.new("0")
    material_budget = BigDecimal.new("0")
    spent = BigDecimal.new("0")

    cost_objects.each do |cost_object|
      total_budget += cost_object.budget
      labor_budget += cost_object.labor_budget
      material_budget += cost_object.material_budget
      spent += cost_object.spent
    end

    {
      total_budget: total_budget,
      labor_budget: labor_budget,
      material_budget: material_budget,
      spent: spent,
      ostatok: total_budget - spent,
      ne_ispoln: 0,
      risk_ispoln: 0
    }

  end

  def self.projects_budgets (projects = [])
    project_ids = projects.map {|p|  p.id}
    elements = []

    projects.each do |project|
      co = cost_by_project project
      elements.push co
    end

    elements
  end

  def self.user_projects_budgets (user)
    self.projects_budgets (user.projects)
  end

  def self.cost_by_project (project)
      CostObject.where(project_id: project.id)
      cost_objects = CostObject.all
      total_budget = BigDecimal.new("0")
      labor_budget = BigDecimal.new("0")
      material_budget = BigDecimal.new("0")
      spent = BigDecimal.new("0")

      cost_objects.each do |cost_object|
        total_budget += cost_object.budget
        labor_budget += cost_object.labor_budget
        material_budget += cost_object.material_budget
        spent += cost_object.spent
      end

      {
        project: project,
        total_budget: total_budget,
        labor_budget: labor_budget,
        material_budget: material_budget,
        spent: spent,
        ostatok: total_budget - spent,
        ne_ispoln: 0,
        progress: spent / total_budget
      }
  end

end