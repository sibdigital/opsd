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

module CostObjectsHelper
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  # Check if the current user is allowed to manage the budget.  Based on Role
  # permissions.
  def allowed_management?
    User.current.allowed_to?(:edit_cost_objects, @project)
  end

  def cost_objects_to_csv(cost_objects)
    CSV.generate(col_sep: t(:general_csv_separator)) do |csv|
      # csv header fields
      headers = ['#',
                 Project.model_name.human,
                 CostObject.human_attribute_name(:subject),
                 CostObject.human_attribute_name(:author),
                 CostObject.human_attribute_name(:fixed_date),
                 VariableCostObject.human_attribute_name(:material_budget),
                 VariableCostObject.human_attribute_name(:labor_budget),
                 CostObject.human_attribute_name(:spent),
                 CostObject.human_attribute_name(:created_on),
                 CostObject.human_attribute_name(:updated_on),
                 CostObject.human_attribute_name(:description)
                ]
      csv << headers.map { |c| begin; c.to_s.encode('UTF-8'); rescue; c.to_s; end }
      # csv lines
      cost_objects.each do |cost_object|
        fields = [cost_object.id,
                  cost_object.project.name,
                  cost_object.subject,
                  cost_object.author.name,
                  format_date(cost_object.fixed_date),
                  cost_object.kind == 'VariableCostObject' ? number_to_currency(cost_object.material_budget) : '',
                  cost_object.kind == 'VariableCostObject' ? number_to_currency(cost_object.labor_budget) : '',
                  cost_object.kind == 'VariableCostObject' ? number_to_currency(cost_object.spent) : '',
                  format_time(cost_object.created_on),
                  format_time(cost_object.updated_on),
                  cost_object.description
                 ]
        csv << fields.map { |c| begin; c.to_s.encode('UTF-8'); rescue; c.to_s; end }
      end
    end
  end

  def budget_attachment_representer(message)
    ::API::V3::Budgets::BudgetRepresenter.new(message,
                                              current_user: current_user,
                                              embed_links: true)
  end

  def render_cost_tree(tree, pid, level)
    html = ''
    tree.each do |cost_object|
      if cost_object.parent_id == pid
        if cost_object.parent_id == nil
          html = html + '<tr id="' + cost_object.id.to_s + '" data-tt-id="' + cost_object.id.to_s + '">'
          html = html + content_tag(:td, link_to(cost_object.id, cost_object_path(id: cost_object.id)))
          tag_td = content_tag(:td, link_to(h(cost_object.subject), cost_object_path(id: cost_object.id), :class => 'subject'))
          html = html + tag_td
        else
          if (has_child(cost_object))
            html = html + '<tr id="' + cost_object.id.to_s + '" data-tt-id="' + cost_object.id.to_s + '" data-tt-parent-id="' + cost_object.parent_id.to_s + '">'
            html = html + content_tag(:td, link_to(cost_object.id, cost_object_path(id: cost_object.id)))
            tag_td = content_tag(:td) do
                link_to(h(cost_object.subject), cost_object_path(id: cost_object.id), :class => 'subject')
            end
            html = html + tag_td
          else
            html = html + '<tr id="' + cost_object.parent_id.to_s + '" data-tt-id="' + cost_object.id.to_s + '" data-tt-parent-id="' + cost_object.parent_id.to_s  + '">'
            html = html + content_tag(:td, link_to(cost_object.id, cost_object_path(id: cost_object.id)))
            tag_td = content_tag(:td) do
                link_to(h(cost_object.subject), cost_object_path(id: cost_object.id), :class => 'subject')
            end
            html = html + tag_td
          end
        end
        html = html + content_tag(:td, cost_object.target, :class => 'target')
        html = html + content_tag(:td, number_to_currency(cost_object.budget, :precision => 0), :class => 'currency')
        sum_spent = sum_spent_in_children(cost_object)
        html = html + content_tag(:td, number_to_currency(sum_spent, :precision => 0), :class => 'currency')
        html = html + content_tag(:td, number_to_currency(cost_object.budget - sum_spent, :precision => 0), :class => 'currency')
        html = html + content_tag(:td, extended_progress_bar(cost_object.budget_ratio, :legend => "#{cost_object.budget_ratio}"))
        html = html + '</tr>'
        html = html + render_cost_tree(CostObject.where(parent_id: cost_object.id), cost_object.id, level + 1)
        html = html + render_unallocated_balance(cost_object.id)
      end
    end
    !html.empty? ? html.html_safe : ''
  end

  def unallocated_balance(parent_id)
    if parent_id != nil && !CostObject.where(parent_id: parent_id).blank?
      result = ActiveRecord::Base.connection.exec_query("WITH parent_costs AS (
        SELECT mbi.cost_type_id as cost_type_id,
               sum(CASE WHEN  mbi.budget IS NULL THEN mbi.units*1
               ELSE mbi.budget
               END) as budget
        FROM cost_objects co
        LEFT JOIN material_budget_items mbi
            ON co.id = mbi.cost_object_id
        WHERE co.id = $1
        GROUP BY mbi.cost_type_id
        ),
        children_cost_objects AS (
            SELECT mbi.cost_type_id as cost_type_id,
                   sum(CASE WHEN  mbi.budget IS NULL THEN mbi.units*1
               ELSE mbi.budget
               END) as budget
            FROM cost_objects co
                     LEFT JOIN material_budget_items mbi
                               ON co.id = mbi.cost_object_id
            WHERE parent_id = $1
            GROUP BY mbi.cost_type_id
        ),
        result_by_type_id AS (
            SELECT
                   COALESCE(parent_costs.cost_type_id, children_cost_objects.cost_type_id) as cost_type_id,
                   COALESCE(parent_costs.budget, 0) - COALESCE(children_cost_objects.budget, 0) as difference,
                   CASE
                       WHEN (COALESCE(parent_costs.budget, 0) - COALESCE(children_cost_objects.budget, 0) < 0)
                        THEN 1
                        ELSE 0
                   END as error
            FROM parent_costs
            FULL OUTER JOIN children_cost_objects
            ON parent_costs.cost_type_id = children_cost_objects.cost_type_id
        ),
        differences as (
            SELECT
                   sum(rbti.difference) as difference,
                   sum(rbti.error) as error_count
            FROM result_by_type_id rbti
        )
        SELECT
           'Остаток' as subject,
            difference as budget,
            error_count as error
        FROM differences;", "Example", [[nil, parent_id]]);
      return result
    end
  end

  def render_unallocated_balance(parent_id)
    green_color = "color: #008000"
    red_color = "color: #ff0000"
    color = green_color
    errors_exist = false

    result = unallocated_balance(parent_id)
    if (!result.blank? && result[0]['error'] > 0)
      color = red_color
      errors_exist = true
    end
    if (!result.blank?)
      html = '<tr id="' + parent_id.to_s + '" data-tt-id="' + (parent_id*100).to_s + '" data-tt-parent-id="' + parent_id.to_s + '">'
      html = html + content_tag(:td, "")
      html = html + content_tag(:td, "Остаток", :style => color)
      if (errors_exist)
        html = html + content_tag(:td, "Превышен расход бюджета по " + result[0]['error'].to_s + " источнику (-ам)", :style => color)
      else
        html = html + content_tag(:td, "")
      end
      html = html + content_tag(:td, number_to_currency(result[0]['budget'], :precision => 0), {:class => 'currency', :style => color})
      html = html + content_tag(:td, number_to_currency(0, :precision => 0), {:class => 'currency', :style => color})
      html = html + content_tag(:td, number_to_currency(result[0]['budget'], :precision => 0), {:class => 'currency', :style => color})
      html = html + content_tag(:td, extended_progress_bar(0))
      html = html + '</tr>'

      return html
    else
      return ""
    end
  end

  def has_child(cost_object)
    children = CostObject.where(parent_id: cost_object.id)
    if children.blank?
      return false
    else
      return true
    end
  end

  def sum_spent_in_children(elem)
    sum = 0
    if (!elem.blank? && !elem.nil?)
      if (elem.instance_of?VariableCostObject)
        sum = sum + elem.spent
        sum = sum + sum_spent_in_children(CostObject.where(parent_id: elem.id))
      else
        elem.each do |cost_object|
          sum = sum + sum_spent_in_children(cost_object)
        end
      end
    end
    return sum
  end
end
