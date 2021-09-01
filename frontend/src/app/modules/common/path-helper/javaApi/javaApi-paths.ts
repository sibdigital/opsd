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

export class JavaApiPaths {
  // Base path
  public readonly javaApiBasePath = this.appBasePath;

  public readonly projects = new SimpleResourceCollection(this.javaApiBasePath, 'projects');

  constructor(readonly appBasePath:string) {
  }

  /**
   * Returns possible subpaths either in this api root or below /projects/:id/
   *
   * @param {string | number} projectIdentifier
   * @returns {Apiv3ProjectPaths | this}
   */
  // public withOptionalProject(projectIdentifier?:string|number):Apiv3ProjectPaths|this {
  //   if (_.isNil(projectIdentifier)) {
  //     return this;
  //   } else {
  //     return this.projects.id(projectIdentifier);
  //   }
  // }
}
