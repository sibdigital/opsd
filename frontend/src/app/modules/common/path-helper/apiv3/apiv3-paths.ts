// -- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
// ++

import {ApiV3WorkPackagesPaths} from 'core-app/modules/common/path-helper/apiv3/work_packages/apiv3-work-packages-paths';
import {Apiv3UsersPaths} from 'core-app/modules/common/path-helper/apiv3/users/apiv3-users-paths';
import {Apiv3ProjectsPaths} from 'core-app/modules/common/path-helper/apiv3/projects/apiv3-projects-paths';
import {SimpleResource, SimpleResourceCollection} from 'core-app/modules/common/path-helper/apiv3/path-resources';
import {Apiv3QueriesPaths} from 'core-app/modules/common/path-helper/apiv3/queries/apiv3-queries-paths';
import {Apiv3ProjectPaths} from 'core-app/modules/common/path-helper/apiv3/projects/apiv3-project-paths';
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";
import {Apiv3TypesPaths} from "core-app/modules/common/path-helper/apiv3/types/apiv3-types-paths";
import {Apiv3GridsPaths} from "core-app/modules/common/path-helper/apiv3/grids/apiv3-grids-paths";
import {Apiv3NewsesPaths} from "core-app/modules/common/path-helper/apiv3/news/apiv3-newses-paths";
import {Apiv3TimeEntriesPaths} from "core-app/modules/common/path-helper/apiv3/time-entries/apiv3-time-entries-paths";
import {Apiv3NotificationsesPaths} from "core-app/modules/common/path-helper/apiv3/notifications/apiv3-notificationses-paths";

export class ApiV3Paths {
  // Base path
  public readonly apiV3Base  = this.appBasePath + '/api/v3';

  // /api/v3/attachments
  public readonly attachments = new SimpleResource(this.apiV3Base, 'attachments');

  // /api/v3/configuration
  public readonly configuration = new SimpleResource(this.apiV3Base, 'configuration');

  // /api/v3/root
  public readonly root = new SimpleResource(this.apiV3Base, '');

  // /api/v3/statuses
  public readonly statuses = new SimpleResourceCollection(this.apiV3Base, 'statuses');

  // /api/v3/relations
  public readonly relations = new SimpleResourceCollection(this.apiV3Base, 'relations');

  // /api/v3/priorities
  public readonly priorities = new SimpleResourceCollection(this.apiV3Base, 'priorities');

  //bbm(
  public readonly diagrams = new SimpleResource(this.apiV3Base, 'diagrams');

  public readonly work_packages_future = new SimpleResourceCollection(this.apiV3Base, 'work_packages_future');

  public readonly work_packages_due = new SimpleResourceCollection(this.apiV3Base, 'work_packages_due');

  public readonly work_packages_due_and_future = new SimpleResourceCollection(this.apiV3Base, 'work_packages_due_and_future');

  public readonly national_projects = new SimpleResource(this.apiV3Base, 'national_projects');

  public readonly national_projects_problems = new SimpleResource(this.apiV3Base, 'national_projects_problems');

  public readonly risk_problem_stat_view = new SimpleResourceCollection(this.apiV3Base, 'views/risk_problem_stat_view');

  public readonly work_package_ispoln_stat_view = new SimpleResourceCollection(this.apiV3Base, 'views/work_package_ispoln_stat_view');

  public readonly quartered_work_package_targets_with_quarter_groups_view = new SimpleResourceCollection(this.apiV3Base, '/views/quartered_work_package_targets_with_quarter_groups_view');

  public readonly work_package_stat_by_proj_view = new SimpleResource(this.apiV3Base, 'views/work_package_stat_by_proj_view');

  public readonly head_performances = new SimpleResourceCollection(this.apiV3Base, 'head_performances');

  public readonly plan_fact_quarterly_target_values_view = new SimpleResource(this.apiV3Base, 'views/plan_fact_quarterly_target_values_view');

  public readonly diagram_queries = new SimpleResourceCollection(this.apiV3Base, 'diagram_queries');

  public readonly organizations = new SimpleResourceCollection(this.apiV3Base, 'organizations');

  public readonly raions = new SimpleResourceCollection(this.apiV3Base, 'raions');

  public readonly attach_types = new SimpleResourceCollection(this.apiV3Base, 'attach_types');

  public readonly problems = new SimpleResource(this.apiV3Base, 'problems');

  public readonly topics = new SimpleResource(this.apiV3Base, 'topics');

  public readonly summary_budgets_users = new SimpleResource(this.apiV3Base, 'summary_budgets/all_user');

  public readonly summary_budgets = new SimpleResource(this.apiV3Base, 'summary_budgets/budget');

  public readonly protocols = new SimpleResource(this.apiV3Base, 'protocols');
  //)

  //iag(
  public readonly meetings = new SimpleResource(this.apiV3Base, 'meetings');
  //)

  // /api/v3/time_entries
  public readonly time_entries = new Apiv3TimeEntriesPaths(this.apiV3Base);

  // /api/v3/news
  public readonly news = new Apiv3NewsesPaths(this.apiV3Base);

  // /api/v3/notifications
  public readonly notifications = new Apiv3NotificationsesPaths(this.apiV3Base);

  // /api/v3/types
  public readonly types = new Apiv3TypesPaths(this.apiV3Base);

  // /api/v3/work_packages
  public readonly work_packages = new ApiV3WorkPackagesPaths(this.apiV3Base);

  // /api/v3/queries
  public readonly queries = new Apiv3QueriesPaths(this.apiV3Base);

  // /api/v3/projects
  public readonly projects = new Apiv3ProjectsPaths(this.apiV3Base);

  // /api/v3/projects
  public readonly projects_for_user = new SimpleResource(this.apiV3Base, 'projects_for_user');

  // /api/v3/users
  public readonly users = new Apiv3UsersPaths(this.apiV3Base);

  // /api/v3/help_texts
  public readonly help_texts = new SimpleResourceCollection(this.apiV3Base, 'help_texts');

  // /api/v3/grids
  public readonly grids = new Apiv3GridsPaths(this.apiV3Base);

  //zbd(
  public readonly targets = new SimpleResourceCollection(this.apiV3Base, 'targets');
  public readonly work_package_targets = new SimpleResourceCollection(this.apiV3Base, 'work_package_targets');
  public readonly work_package_problems = new SimpleResourceCollection(this.apiV3Base, 'work_package_problems');
  public readonly project_risks = new SimpleResourceCollection(this.apiV3Base, 'project_risks');
  public readonly plan_fact_quarterly_target_values = new SimpleResourceCollection(this.apiV3Base, 'plan_fact_quarterly_target_values');
  // )


  constructor(readonly appBasePath:string) {
  }

  /**
   * Returns possible subpaths either in this api root or below /projects/:id/
   *
   * @param {string | number} projectIdentifier
   * @returns {Apiv3ProjectPaths | this}
   */
  public withOptionalProject(projectIdentifier?:string|number):Apiv3ProjectPaths|this {
    if (_.isNil(projectIdentifier)) {
      return this;
    } else {
      return this.projects.id(projectIdentifier);
    }
  }

  public previewMarkup(context:string) {
    let base = this.apiV3Base + '/render/markdown';

    if (context) {
      return base + `?context=${context}`;
    } else {
      return base;
    }
  }

  public principals(projectId:string|number, term:string|null) {
    let filters:ApiV3FilterBuilder = new ApiV3FilterBuilder();
    // Only real and activated users:
    filters.add('status', '!', ['0', '3']);
    // that are members of that project:
    filters.add('member', '=', [projectId.toString()]);
    // That are users:
    filters.add('type', '=', ['User', 'Group']);
    // That are not the current user:
    filters.add('id', '!', ['me']);

    if (term && term.length > 0) {
      // Containing the that substring:
      filters.add('name', '~', [term]);
    }
    return this.apiV3Base + '/principals' + '?' + filters.toParams() + encodeURI('&sortBy=[["name","asc"]]&offset=1&pageSize=10');
  }

  public wpBySubjectOrId(term:string, idOnly:boolean = false) {
    let filters:ApiV3FilterBuilder = new ApiV3FilterBuilder();

    if (idOnly) {
      filters.add('id', '=', [term]);
    } else {
      filters.add('subjectOrId', '**', [term]);
    }

    return this.apiV3Base + '/work_packages' + '?' + filters.toParams() + encodeURI('&sortBy=[["updatedAt","desc"]]&offset=1&pageSize=10');
  }

  public wpByProject(projectId:string) {
    return this.apiV3Base + '/projects/' + projectId + '/work_packages';
  }
}
