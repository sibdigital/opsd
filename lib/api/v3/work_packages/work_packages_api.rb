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

require 'api/v3/work_packages/work_package_representer'
require 'api/v3/work_packages/create_work_packages'

module API
  module V3
    module WorkPackages
      class WorkPackagesAPI < ::API::OpenProjectAPI
        resources :work_packages do
          helpers ::API::V3::WorkPackages::CreateWorkPackages

          # The endpoint needs to be mounted before the GET :work_packages/:id.
          # Otherwise, the matcher for the :id also seems to match available_projects.
          # This is also true when the :id param is declared to be of type: Integer.
          mount ::API::V3::WorkPackages::AvailableProjectsOnCreateAPI
          mount ::API::V3::WorkPackages::Schema::WorkPackageSchemasAPI

          get do
            if params['type']
              if params['type'] == 'ancestors'
                work_packages = WorkPackage.where(id: JSON.parse(params[:filters])[0]['id']['values'])
                ::API::V3::WorkPackages::WorkPackageCollectionRepresenter.new(
                  work_packages,
                  api_v3_paths.work_packages,
                  groups: nil,
                  page: params[:offset] ? params[:offset].to_i : nil,
                  per_page: params[:pageSize] ? params[:pageSize].to_i : nil,
                  total_sums: nil,
                  embed_schemas: true,
                  current_user: current_user)
              end
            else
              authorize(:view_work_packages, global: true)
              service = WorkPackageCollectionFromQueryParamsService
                        .new(current_user)
                        .call(params)

              if service.success?
                service.result
              else
                api_errors = service.errors.full_messages.map do |message|
                  ::API::Errors::InvalidQuery.new(message)
                end

                raise ::API::Errors::MultipleErrors.create_if_many api_errors
              end
              end
          end

          post do
            create_work_packages(request_body, current_user)
          end

          params do
            requires :id, desc: 'Work package id', type: Integer
          end
          route_param :id do
            helpers WorkPackagesSharedHelpers

            helpers do
              attr_reader :work_package
            end

            before do
              @work_package = WorkPackage.find(params[:id])

              authorize(:view_work_packages, context: @work_package.project) do
                raise API::Errors::NotFound.new
              end
            end

            get do
              work_package_representer
            end

            patch do
              #bbm(
              if request_body['days']
                start_date = @work_package.start_date
                if start_date
                  #due = start_date + request_body['days'].to_i
                  days = request_body['days'].to_i
                  pcalendar = ProductionCalendar.where('date >= ?',start_date)
                  working_days = []
                  Setting.where(name: 'work_days').map do |i|
                    working_days = i.value.digits.to_a
                  end
                  i = 1
                  current = start_date
                  while i <= days
                    current += 1
                    cal = pcalendar.find_by(date: current) rescue nil
                    if cal
                      if cal.day_type == 0
                        i += 1
                      end
                    else
                      if working_days.include? current.wday
                        i += 1
                      end
                    end
                  end
                  request_body['dueDate'] = current.to_s
                end
                request_body.delete('days')
              end
              # )
              parameters = ::API::V3::WorkPackages::ParseParamsService
                           .new(current_user)
                           .call(request_body)
                           .result

              call = ::WorkPackages::UpdateService
                     .new(
                       user: current_user,
                       work_package: @work_package
                     )
                     .call(attributes: parameters, send_notifications: notify_according_to_params)

              if call.success?
                @work_package.reload

                work_package_representer
              else
                handle_work_package_errors @work_package, call
              end
            end

            #ban(
            # route_param :assigned_to_id do
            #   before do
            #     @work_package.update(assigned_to_id: params[:assigned_to_id])
            #   end
            #   get do
            #     message_assigned = 'Информация обновлена'
            #     message_assigned
            #   end
            # end
            # )

            delete do
              authorize(:delete_work_packages, context: @work_package.project)

              call = ::WorkPackages::DestroyService
                     .new(
                       user: current_user,
                       work_package: @work_package
                     )
                     .call

              if call.success?
                status 204
              else
                fail ::API::Errors::ErrorBase.create_and_merge_errors(call.errors)
              end
            end

            mount ::API::V3::WorkPackages::WatchersAPI
            mount ::API::V3::Activities::ActivitiesByWorkPackageAPI
            mount ::API::V3::Attachments::AttachmentsByWorkPackageAPI
            mount ::API::V3::Repositories::RevisionsByWorkPackageAPI
            mount ::API::V3::WorkPackages::UpdateFormAPI
            mount ::API::V3::WorkPackages::AvailableProjectsOnEditAPI
            mount ::API::V3::WorkPackages::AvailableRelationCandidatesAPI
            mount ::API::V3::WorkPackages::WorkPackageRelationsAPI

            #zbd(
            mount ::API::V3::WorkPackageTargets::WorkPackageTargetsAPI
            # )
          end

          mount ::API::V3::WorkPackages::CreateFormAPI
        end
      end
    end
  end
end
