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

require "set"

class TargetQuery::Filter < Report::Filter
  def self.all
    @all ||= super + Set[
       #TargetQuery::Filter::CreatedOn,
       TargetQuery::Filter::ProjectId,
       #TargetQuery::Filter::StatusId,
       TargetQuery::Filter::TargetId
       #TargetQuery::Filter::UserId #,
       #TargetQuery::Filter::UpdatedOn,
       #TargetQuery::Filter::PermissionFilter
    ]
  end
end
