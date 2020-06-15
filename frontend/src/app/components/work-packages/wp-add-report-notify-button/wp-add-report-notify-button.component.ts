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
import {HttpClient} from "@angular/common/http";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";

@Component({
  templateUrl: './wp-add-report-notify-button.html',
  selector: 'wp-add-report-notify-button',
})
export class WorkPackageAddReportNotifyButtonComponent  implements OnInit,  OnDestroy {
  @Input('workPackage') public workPackage:WorkPackageResource;
  @Input('workPackageId') public workPackageId:string;
  @Input('showText') public showText:boolean = false;
  @Input('disabled') public disabled:boolean = false;
  public buttonText:string = this.I18n.t('js.label_send_notify');
  public buttonTitle:string = this.I18n.t('js.label_send_notify');
  public buttonClass:string;
  public buttonId:string = 'wp-add-report-notify-button';
  public watchIconClass:string = 'icon-mail1';

  constructor(readonly I18n:I18nService,
              private readonly PathHelper:PathHelperService,
              readonly http:HttpClient,
              protected NotificationsService:NotificationsService,
              readonly wpCacheService:WorkPackageCacheService) {
  }

  ngOnInit() {
  }

  ngOnDestroy() {
    // Nothing to do
  }

  sendNotify() {
    const url = this.PathHelper.appBasePath + '/admin/send_email_assignee_report?workPackageId=' + this.workPackageId;

    this.http.get(url).toPromise().then((response) => {
        //this.NotificationsService.addSuccess(this.text.successful_delete);
        this.NotificationsService.addSuccess("Уведомление отправлено");
      })
      .catch((error) => {
        console.log(error);
        this.NotificationsService.addSuccess("Уведомление отправлено");
      });
  }
}

