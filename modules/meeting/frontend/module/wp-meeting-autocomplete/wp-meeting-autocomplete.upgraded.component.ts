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

import {Component, ElementRef} from '@angular/core';
import {PathHelperService} from 'core-app/modules/common/path-helper/path-helper.service';
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';
import {WorkPackageResource} from 'core-app/modules/hal/resources/work-package-resource';
import {UserResource} from 'core-app/modules/hal/resources/user-resource';
import {CollectionResource} from 'core-app/modules/hal/resources/collection-resource';
import {MatDialog} from "@angular/material";
import {HalResourceService} from 'core-app/modules/hal/services/hal-resource.service';
import {PeriodicElement, WpMeetingDialogComponent} from "../wp-meeting-dialog/wp-meeting-dialog.component";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {StateService} from "@uirouter/core";

@Component({
  selector: 'wp-meeting-autocomplete-upgraded',
  templateUrl: './wp-meeting-autocomplete.upgraded.html'
})
export class WpMeetingAutocompleteComponent {
  public selectedWP: string = '';
  public selectedWPid: string;
  public currentUserId: string;
  private dialogOpened=false; // maybe try await
  private projectID: string;
  constructor(readonly pathHelper:PathHelperService,
              readonly element:ElementRef,
              protected halResourceService:HalResourceService,
              readonly $state:StateService,
              readonly I18n:I18nService,
              public dialog:MatDialog) {

  }

  ngOnInit(){

    if (this.element.nativeElement.getAttribute('projectObject'))
    {
     this.projectID = JSON.parse(this.element.nativeElement.getAttribute('projectObject'));
    }
    this.halResourceService.get<CollectionResource<UserResource>>(this.pathHelper.api.v3.users.me.toString()).toPromise().then((usrs: CollectionResource<UserResource>)=>{
      this.currentUserId = usrs.id;
    });
    if (this.element.nativeElement.getAttribute('wpId')) {

      this.selectedWPid = JSON.parse(this.element.nativeElement.getAttribute('wpId'));
      this.halResourceService
        .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.wpBySubjectOrId(this.selectedWPid, true).toString())
        .toPromise()
        .then((wps: CollectionResource<WorkPackageResource>) => {
          if (wps.count > 0) {
            this.selectedWP = wps.elements[0].subject || '';
          }
        });
    }
  }
  //bbm(
  openDialog():void {
    let ELEMENT_DATA:PeriodicElement[] = [];

    if (!this.dialogOpened) {
      this.halResourceService
        .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.wpByProject(this.projectID).toString(), {pageSize: 1024})
        //.get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages.toString(), {pageSize: 1024})
        .toPromise()
        .then((values: CollectionResource<WorkPackageResource>) => {
          values.elements.map(wp => {
            // if (wp.assignee.idFromLink == this.currentUserId)
            // {
              ELEMENT_DATA.push({
                id: wp.id,
                subject: wp.subject,
                type: wp.type.$link.title,
                status: wp.status.$link.title,
                assignee: wp.assignee ? wp.assignee.$link.title : null
              });
            // }
          });
          const dialogRef = this.dialog.open(WpMeetingDialogComponent, {
            height: '680px',
            // width: '1050px',
            data: ELEMENT_DATA
          });
          this.dialogOpened = true;
          dialogRef.afterClosed().subscribe(result => {
            if (result) {
              this.selectedWP = result.subject;
              this.selectedWPid = result.id;

            }
            this.dialogOpened = false;
          });
        });
    }
    this.dialogOpened=true;
  }
}
