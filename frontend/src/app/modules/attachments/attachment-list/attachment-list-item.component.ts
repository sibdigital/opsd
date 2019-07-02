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

import {Component, Input, OnInit} from '@angular/core';
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';
import {PathHelperService} from 'core-app/modules/common/path-helper/path-helper.service';
import {HalResource} from 'core-app/modules/hal/resources/hal-resource';
import {States} from 'core-components/states.service';
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";

export interface ValueOption {
  name:string;
  $href:string | null;
}

@Component({
  selector: 'attachment-list-item',
  templateUrl: './attachment-list-item.html',
  styleUrls: ['./attachment-list-item.sass']
})
export class AttachmentListItemComponent implements OnInit {
  @Input() public resource:HalResource;
  @Input() public attachment:any;
  @Input() public index:any;
  @Input() public selfDestroy?:boolean;
  //bbm(
  public options:any[];
  private value:{ [attribute:string]:any } = {};
  public valueOptions:ValueOption[];
  public compareByHref = AngularTrackingHelpers.compareByHref;
  //)

  static imageFileExtensions:string[] = ['jpeg', 'jpg', 'gif', 'bmp', 'png'];

  public text = {
    //bbm(
    requiredPlaceholder: this.I18n.t('js.placeholders.selection'),
    placeholder: this.I18n.t('js.placeholders.default'),
    successful: this.I18n.t('js.notice_successful_update'),
    //)
    dragHint: this.I18n.t('js.attachments.draggable_hint'),
    destroyConfirmation: this.I18n.t('js.text_attachment_destroy_confirmation'),
    removeFile: (arg:any) => this.I18n.t('js.label_remove_file', arg)
  };

  constructor(protected wpNotificationsService:WorkPackageNotificationService,
              readonly I18n:I18nService,
              readonly states:States,
              //bbm(
              readonly notificationsService:NotificationsService,
              public halResourceService:HalResourceService,
              //)
              readonly pathHelper:PathHelperService) {
    this.initialize();
  }

  //bbm(
  ngOnInit():void {
    let attachType:any = this.attachment.attachType;
    if (attachType) {
      const resource = this.halResourceService.createHalResourceOfType('HalResource', this.attachment.attachType.$source);
      this.value = {name: resource.name, $href: resource.$href};
    } else {
      this.value = {name: "-", $href: ""};
    }
  }

  protected initialize() {
    this.setValues();
  }

  protected setValues() {
    this.loadAttachTypes()
      .then((attachTypes:CollectionResource) => {
        this.options = attachTypes.elements;
        this.addEmptyOption();
        this.valueOptions = this.options.map(el => {
          return {name: el.name, $href: el.$href};
        });
      });
  }

  private addEmptyOption() {
    const emptyOption = _.find(this.options, el => el.name === this.text.placeholder);
    if (emptyOption === undefined) {
      this.options.unshift({
        name: this.text.placeholder,
        $href: ''
      });
    }
  }

  protected loadAttachTypes() {
    const url = this.pathHelper.api.v3.attachTypes.toString();
    return this.halResourceService.get<CollectionResource<HalResource>>(url).toPromise();
  }

  public handleUserSubmit() {
    if (this.selectedOption && this.selectedOption.$href) {
      this.halResourceService.get<HalResource>(this.selectedOption.$href).toPromise()
        .then((attachType:HalResource) => {
          let attachTypeId:string = attachType.getId();
          this.attachment.updateImmediately({attach_type_id: attachTypeId})
            .then(() => {
              this.notificationsService.addSuccess(this.text.successful);
            })
            .catch((error:any) => {
              this.notificationsService.addError(error);
            });
        });
    }
    else {
      this.attachment.updateImmediately()
        .then(() => {
          this.notificationsService.addSuccess(this.text.successful);
        })
        .catch((error:any) => {
          this.notificationsService.addError(error);
        });
      this.value = {name: "-", $href: ""};
    }
  }

  public get selectedOption() {
    const href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === href)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.options, o => o.$href === val.$href);

    // Special case 'null' value, which angular
    // only understands in ng-options as an empty string.
    if (option && option.$href === '') {
      option.$href = null;
    }

    this.value = option;
  }
  //)

  /**
   * Set the appropriate data for drag & drop of an attachment item.
   * @param evt DragEvent
   */
  public setDragData(evt:DragEvent) {
    const url = this.downloadPath;
    const previewElement = this.draggableHTML(url);

    evt.dataTransfer!.setData("text/plain", url);
    evt.dataTransfer!.setData("text/html", previewElement.outerHTML);
    evt.dataTransfer!.setData("text/uri-list", url);
    evt.dataTransfer!.setDragImage(previewElement, 0, 0);
  }

  public draggableHTML(url:string) {
    let el:HTMLImageElement|HTMLAnchorElement;

    if (this.isImage) {
      el = document.createElement('img') as HTMLImageElement;
      el.src = url;
      el.textContent = this.fileName;
    } else {
      el = document.createElement('a') as HTMLAnchorElement;
      el.href = url;
      el.textContent = this.fileName;
    }

    return el;
  }

  public get downloadPath() {
    return this.pathHelper.attachmentDownloadPath(this.attachment.id, this.fileName);
  }

  public get isImage() {
    const ext = this.fileName.split('.').pop() || '';
    return AttachmentListItemComponent.imageFileExtensions.indexOf(ext.toLowerCase()) > -1;
  }

  public get fileName() {
    const a = this.attachment;
    return a.fileName || a.customName || a.name;
  }

  public confirmRemoveAttachment($event:JQueryEventObject) {
    if (!window.confirm(this.text.destroyConfirmation)) {
      $event.stopImmediatePropagation();
      $event.preventDefault();
      return false;
    }

    _.pull(this.resource.attachments.elements, this.attachment);
    this.states.forResource(this.resource!).putValue(this.resource);

    if (!!this.selfDestroy) {
      this
        .resource
        .removeAttachment(this.attachment);
    }

    return false;
  }
}
