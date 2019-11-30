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
import {Component, Input, OnDestroy, OnInit} from '@angular/core';
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';
import {WorkPackageCacheService} from "core-components/work-packages/work-package-cache.service";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {takeUntil} from "rxjs/operators";
import {componentDestroyed} from "ng2-rx-componentdestroyed";
import {HttpClient, HttpHeaders, HttpParams} from "@angular/common/http";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {ProjectCacheService} from "core-components/projects/project-cache.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";

@Component({
  templateUrl: './create-board-button.html',
  selector: 'create-board-button',
})
export class CreateBoardButtonComponent  implements OnInit,  OnDestroy {
  @Input('workPackage') public workPackage:WorkPackageResource;
  @Input('projectIdentifier') public projectIdentifier:string;
  @Input('boardIdentifier') public boardIdentifier:string;
  @Input('showText') public showText:boolean = false;
  @Input('disabled') public disabled:boolean = true;
  public buttonText:string = this.I18n.t('js.label_create_board');
  public buttonTitle:string = this.I18n.t('js.label_create_board');
  public buttonClass:string;
  public buttonId:string = 'create-board-button';
  public watchIconClass:string = 'icon-forums';
  public text:string = '';

  constructor(readonly I18n:I18nService,
              private readonly PathHelper:PathHelperService,
              readonly http:HttpClient,
              protected NotificationsService:NotificationsService,
              readonly wpCacheService:WorkPackageCacheService,
              readonly projectCacheService:ProjectCacheService,
              readonly halResourceService:HalResourceService) {
  }

  ngOnInit() {
    this.wpCacheService.loadWorkPackage(this.workPackage.id)
      .values$()
      .pipe(takeUntil(componentDestroyed(this))      )
      .subscribe((wp:WorkPackageResource) => {
        this.workPackage = wp;
        // let path = wp.project.href;
        this.halResourceService
          .get<HalResource>(wp.project.href)
          .toPromise()
          .then((resource:HalResource) => {
            this.projectIdentifier = resource.id;
            this.boardIdentifier = resource.defaultBoard.id;
            if (resource.defaultBoard) {
              this.disabled = false;
            }
          });
        // this.projectIdentifier = wp.project.id;
        // wp.source._links.project.href
        // this.boardIdentifier = wp.project.defaultBoard;
      });
    // this.projectCacheService
    //   .require(this.workPackage.project.idFromLink)
    //   .then(() => {
    //     this.projectIdentifier = this.workPackage.project.identifier;
    //     this.boardIdentifier = this.workPackage.project.defaultBoard;
    //   });
      // .require(this.workPackage.project.idFromLink)
      // .then(() => {
      //   this.projectIdentifier = this.workPackage.project.identifier;
      //   this.boardIdentifier = this.workPackage.project.defaultBoard;
      // });
  }

  ngOnDestroy() {
    // Nothing to do
  }

  createBoard() {
    // this.projectIdentifier = this.workPackage.project.id;
    // this.boardIdentifier = this.workPackage.project.defaultBoard;
    const url = this.PathHelper.newTopicPath(this.projectIdentifier, this.boardIdentifier, this.workPackage.id);
    let params = new HttpParams().set("wpId", this.workPackage.id);
    const headers = new HttpHeaders().set('Content-Type', 'text/plain; charset=utf-8');
    const promise = this.http.get(url, {params: params}).toPromise();

    promise
      .then((response) => {
        this.NotificationsService.addSuccess(this.buttonText);
        this.NotificationsService.addSuccess("");
        // return response;
      })
      .catch((error) => {
        window.location.href = url;
        // this.NotificationsService.addError(error);
      });
  }
}

