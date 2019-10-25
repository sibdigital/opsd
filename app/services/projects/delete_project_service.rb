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

module Projects
  class DeleteProjectService
    attr_accessor :user, :project
    include Concerns::Contracted

    def initialize(user:, project:)
      self.user = user
      self.project = project
      self.contract_class = ::Projects::DeleteContract
    end

    ##
    # Deletes the given user if allowed.
    #
    # @return True if the project deletion has been initiated, false otherwise.
    def call(delayed: true)
      result, errors = validate_and_yield(project, user) { delete_or_schedule_deletion(delayed) }
      ServiceResult.new(success: result, errors: errors)
    end

    private

    def delete_or_schedule_deletion(delayed)
      if delayed
        # Archive the project
        project.archive
        Delayed::Job.enqueue DeleteProjectJob.new(user_id: user.id, project_id: project.id),
                             priority: ::ApplicationJob.priority_number(:low)
        true
      else
        delete_project!
      end
    end

    def delete_project!
      OpenProject::Notifications.send('project_deletion_imminent', project: @project_to_destroy)

      begin
        if project.destroy
          ProjectMailer.delete_project_completed(project, user: user).deliver_now
          true
        else
          ProjectMailer.delete_project_failed(project, user: user).deliver_now
          false
        end
      rescue Exception => e
        Rails.logger.info(e.message)
      end

    end
  end
end
