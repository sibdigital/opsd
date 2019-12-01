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

class TargetQuery::Result < Report2::Result
  module BaseAdditions
    def inspect
      "<##{self.class}: @fields=#{fields.inspect} @type=#{type.inspect} " \
      "@size=#{size} @count=#{count} @units=#{units} @plan_value=#{plan_value} @value=#{value}>"
    end

    # def display_value?
    #   display_values > 0
    # end
  end

  class Base < Report2::Result::Base
    include BaseAdditions
  end

  class DirectResult < Report2::Result::DirectResult
    include BaseAdditions
    # def display_value
    #   self["display_values"].to_i
    # end

    def plan_value
      (self["plan_value"] || 0).to_d # if display_values? # FIXME: default value here?
    end

    def value
      (self["value"] || 0).to_d # if display_values? # FIXME: default value here?
    end
  end

  class WrappedResult < Report2::Result::WrappedResult
    include BaseAdditions
    # def display_values
    #   (sum_for :display_values) >= 1 ? 1 : 0
    # end

    def plan_value
      sum_for :plan_value #if display_values?
    end

    def value
      sum_for :value #if display_values?
    end
  end
end
