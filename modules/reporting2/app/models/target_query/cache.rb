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

module TargetQuery::Cache
  class << self

    def check
      reset! if reset_required?
    end

    def reset!
      update_reset_on

      TargetQuery::Filter.reset!
      #TargetQuery::Filter::CustomFieldEntries.reset!
      TargetQuery::GroupBy.reset!
      #TargetQuery::GroupBy::CustomFieldEntries.reset!
    end

    protected

    attr_accessor :latest_custom_field_change,
                  :custom_field_count

    def invalid?
      changed_on = fetch_latest_custom_field_change
      field_count = fetch_current_custom_field_count

      latest_custom_field_change != changed_on ||
        custom_field_count != field_count
    end

    def update_reset_on
      return if caching_disabled?

      self.latest_custom_field_change = fetch_latest_custom_field_change
      self.custom_field_count = fetch_current_custom_field_count
    end

    def fetch_latest_custom_field_change
      WorkPackageCustomField.maximum(:updated_at)
    end

    def fetch_current_custom_field_count
      WorkPackageCustomField.count
    end

    def caching_disabled?
      !OpenProject::Configuration.target_reporting_cache_filter_classes
      #true
    end

    def reset_required?
      caching_disabled? || invalid?
      #true
    end
  end

  # initialize to 0 to avoid forced cache reset on first request
  self.custom_field_count = 0
end
