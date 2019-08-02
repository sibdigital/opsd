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

# Root class of the API v3
# This is the place for all API v3 wide configuration, helper methods, exceptions
# rescuing, mounting of different API versions etc.

module API
  module V3
    class Root < ::API::OpenProjectAPI
      mount ::API::V3::Activities::ActivitiesAPI
      mount ::API::V3::Attachments::AttachmentsAPI
      mount ::API::V3::Categories::CategoriesAPI
      #zbd(
      mount ::API::V3::Contracts::ContractsAPI
      mount ::API::V3::Targets::TargetsAPI
      mount ::API::V3::WorkPackageTargets::WorkPackageTargetsAPI
      mount ::API::V3::WorkPackageProblems::WorkPackageProblemsAPI
      # )
      mount ::API::V3::Configuration::ConfigurationAPI
      mount ::API::V3::CustomActions::CustomActionsAPI
      mount ::API::V3::CustomOptions::CustomOptionsAPI
      mount ::API::V3::HelpTexts::HelpTextsAPI
      mount ::API::V3::News::NewsAPI
      #xcc(
      mount ::API::V3::Organizations::OrganizationsAPI
      mount ::API::V3::ArbitaryObjects::ArbitaryObjectsAPI
      # )
      mount ::API::V3::Posts::PostsAPI
      mount ::API::V3::Principals::PrincipalsAPI
      mount ::API::V3::Priorities::PrioritiesAPI
      #bbm(
      mount ::API::V3::AttachTypes::AttachTypesAPI
      mount ::API::V3::Diagrams::DiagramsAPI
      mount ::API::V3::DiagramQueries::DiagramQueriesAPI
      mount ::API::V3::NationalProjects::NationalProjectsAPI
      mount ::API::V3::Problems::ProblemsAPI
      mount ::API::V3::WorkPackageTargets::WorkPackageTargetsAPI
      mount ::API::V3::Protocols::ProtocolsAPI
      # )
      # +tan 2019.07.30
      mount ::API::V3::Boards::BoardsAPI
      mount ::API::V3::Raions::RaionsAPI
      # - tan
      mount ::API::V3::Projects::ProjectsAPI
      mount ::API::V3::Queries::QueriesAPI
      mount ::API::V3::Render::RenderAPI
      mount ::API::V3::Relations::RelationsAPI
      mount ::API::V3::Repositories::RevisionsAPI
      mount ::API::V3::Roles::RolesAPI
      mount ::API::V3::Statuses::StatusesAPI
      mount ::API::V3::StringObjects::StringObjectsAPI
      mount ::API::V3::TimeEntries::TimeEntriesAPI
      mount ::API::V3::Types::TypesAPI
      mount ::API::V3::Users::UsersAPI
      mount ::API::V3::UserPreferences::UserPreferencesAPI
      mount ::API::V3::Groups::GroupsAPI
      mount ::API::V3::Versions::VersionsAPI
      mount ::API::V3::WorkPackages::WorkPackagesAPI
      mount ::API::V3::WikiPages::WikiPagesAPI
      mount ::API::V3::Grids::GridsAPI

      get '/' do
        RootRepresenter.new({}, current_user: current_user)
      end
    end
  end
end
