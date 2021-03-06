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

class TargetQuery::SqlStatement < Report2::SqlStatement
  COMMON_FIELDS = %w[
    project_id target_id work_package_id plan_value value
  ].freeze

  # flag to mark a reporting query consisting of a union of cost and time entries
  # attr_accessor :entry_union

  def initialize(table, desc = "")
    super(table, desc)
    # @entry_union = false
  end

  # this is a hack to ensure that additional joins added by filters do not result
  # in additional columns being selected.
  def to_s
    # select(['work_package_targets.*']) #if select == ['*'] && group_by.empty? && self.entry_union
    super
  end

  # @param [#table_name] model The model to map
  # @return [TargetQuery::SqlStatement] Generated statement
  def self.unified_entry(model)
    table = table_name_for model
    new(table).tap do |query|
      query.select COMMON_FIELDS
      # query.desc = "Subquery for #{table}"
      query.select(
        count: 1,
        id: [model, :id],
        year: [model, :year],
        quarter: [model, :quarter],
        # plan_value: [model, :plan_value],
        # value: [model, :value],
        month: [model, :month],
        # real_costs: switch("#{table}.overridden_costs IS NULL" => [model, :costs], else: [model, :overridden_costs]),
        # week: iso_year_week(:spent_on, model),
        # quarter: iso_year_quarter(:quarter),
        singleton_value: 1
      )
      # FIXME: build this subquery from a sql_statement
      # query.from "(SELECT * FROM #{table}) AS #{table}"
      query.from table.to_s
      # send("unify_#{table}", query)
    end
  end

  def self.for_targets
    sql = new unified_entry(WorkPackageTarget).as(WorkPackageTarget)
    sql
  end

end
