//-- copyright
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
//++

import {HalResourceService} from 'core-app/modules/hal/services/hal-resource.service';
import {Inject, Injectable} from '@angular/core';
import {WpTargetResource} from 'core-app/modules/hal/resources/wp-target-resource';
import {buildApiV3Filter} from 'core-app/components/api/api-v3/api-v3-filter-builder';
import {CollectionResource} from 'core-app/modules/hal/resources/collection-resource';
import {PathHelperService} from 'core-app/modules/common/path-helper/path-helper.service';
import {TargetResource} from "core-app/modules/hal/resources/target-resource";

@Injectable()
export class WpTargetsDmService {

  constructor(private halResourceService:HalResourceService,
              private pathHelper:PathHelperService) {

  }

  public load(workPackageId:string):Promise<WpTargetResource[]> {
    return this.halResourceService.get<CollectionResource<WpTargetResource>>(
      //this.pathHelper.api.v3.work_packages.id(workPackageId).relations, {})
      this.pathHelper.api.v3.work_packages.toString() + '/' + workPackageId + '/work_package_targets', {} )
      .toPromise()
      .then((collection:CollectionResource<WpTargetResource>) => collection.elements);
  }

  public loadTargets(project_id:string):Promise<TargetResource[]> {
    return this.halResourceService
      .get<CollectionResource<TargetResource>>(this.pathHelper.api.v3.targets.toString() + '?project_id=' + project_id)
      .toPromise()
      .then((collection:CollectionResource<TargetResource>) => collection.elements);
  }
}
