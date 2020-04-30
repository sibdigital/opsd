#-- encoding: UTF-8

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

class WorkPackages::DestroyService
  include ::WorkPackages::Shared::UpdateAncestors
  include ::Shared::ServiceContext

  attr_accessor :user, :work_package

  def initialize(user:, work_package:)
    self.user = user
    self.work_package = work_package
  end

  def call
    in_context(true) do
      destroy
    end
  end

  private

  def destroy
    result = ServiceResult.new success: true,
                               result: work_package

    descendants = work_package.descendants.to_a

    result.success = work_package.destroy
    if work_package.assigned_to.present?
      Alert.create_pop_up_alert(work_package, "Deleted", User.current, work_package.assigned_to)
    end
    if result.success?
      update_ancestors_all_attributes(result.all_results).each do |ancestor_result|
        result.merge!(ancestor_result)
      end

      destroy_descendants(descendants, result)
    end

    result
  end

  def destroy_descendants(descendants, result)
    descendants.each do |descendant|
      result.add_dependent!(ServiceResult.new(success: descendant.destroy, result: descendant))
    end
  end
end
