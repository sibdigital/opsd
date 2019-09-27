#-- copyright
# OpenProject Reporting Plugin
#
# Copyright (C) 2010 - 2014 the OpenProject Foundation (OPF)
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

class TargetQuery::SqlStatement < Report::SqlStatement
  COMMON_FIELDS = %w[
    project_id created_on updated_on target_id quarter year month plan_value value
  ]

  # flag to mark a reporting query consisting of a union of cost and time entries
  #attr_accessor :entry_union

  def initialize(table, desc = "")
    super(table, desc)
    #@entry_union = false
  end

  # this is a hack to ensure that additional joins added by filters do not result
  # in additional columns being selected.
  def to_s
    select(['work_package_targets.*']) #if select == ['*'] && group_by.empty? && self.entry_union
    super
  end

  ##
  # Generates SqlStatement that maps time_entries and cost_entries to a common structure.
  #
  # Mapping for direct fields:
  #
  #   Result                    | Time Entires             | Cost entries
  #   --------------------------|--------------------------|--------------------------
  #   id                        | id                       | id
  #   user_id                   | user_id                  | user_id
  #   project_id                | project_id               | project_id
  #   work_package_id           | work_package_id          | work_package_id
  #   rate_id                   | rate_id                  | rate_id
  #   comments                  | comments                 | comments
  #   spent_on                  | spent_on                 | spent_on
  #   created_on                | created_on               | created_on
  #   updated_on                | updated_on               | updated_on
  #   tyear                     | tyear                    | tyear
  #   tmonth                    | tmonth                   | tmonth
  #   tweek                     | tweek                    | tweek
  #   costs                     | costs                    | costs
  #   overridden_costs          | overridden_costs         | overridden_costs
  #   units                     | hours                    | units
  #   activity_id               | activity_id              | -1
  #   cost_type_id              | -1                       | cost_type_id
  #   type                      | "TimeEntry"              | "CostEntry"
  #   count                     | 1                        | 1
  #
  # Also: This _should_ handle joining activities and cost_types, as the logic differs for time_entries
  # and cost_entries.
  #
  # @param [#table_name] model The model to map
  # @return [TargetQuery::SqlStatement] Generated statement
  def self.unified_entry(model)
    table = table_name_for model
    new(table).tap do |query|
      #query.select COMMON_FIELDS
      #query.desc = "Subquery for #{table}"
      #query.select({
        #count: 1, id: [model, :id], display_costs: 1,
        #real_costs: switch("#{table}.overridden_costs IS NULL" => [model, :costs], else: [model, :overridden_costs]),
        #week: iso_year_week(:spent_on, model),
        #quarter: iso_year_quarter(:spent_on),
        #singleton_value: 1 })
      #FIXME: build this subquery from a sql_statement
      query.from "#{table}" #"(SELECT * FROM #{table}) AS #{table}"
      #send("unify_#{table}", query)
    end
  end

  ##
  # Generates a statement based on all entries (i.e. time entries and cost entries) mapped to the general entries structure,
  # and therefore usable by filters and such.
  #
  # @return [TargetQuery::SqlStatement] Generated statement
  def self.for_entries
    sql = new unified_entry(WorkPackageTarget)
    #sql.entry_union = true
    sql
  end
end
