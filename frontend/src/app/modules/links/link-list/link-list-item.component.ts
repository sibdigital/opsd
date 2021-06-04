import {Component, Input, OnInit} from "@angular/core";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {States} from "core-components/states.service";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {OPContextMenuService} from "core-components/op-context-menu/op-context-menu.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";

@Component({
  selector: 'link-list-item',
  templateUrl: './link-list-item.html',
  styleUrls: ['./link-list-item.sass']
})
export class LinkListItemComponent {
  @Input() public resource:HalResource;
  @Input() public link:any;
  @Input() public index:any;
  @Input() public selfDestroy?:boolean;

  public text = {};

  public edit = false;
  constructor(protected wpNotificationsService:WorkPackageNotificationService,
              readonly I18n:I18nService,
              readonly states:States,
              readonly notificationsService:NotificationsService,
              public halResourceService:HalResourceService,
              protected opContextMenu:OPContextMenuService,
              readonly pathHelper:PathHelperService) {
  }

  confirmRemoveLink(event:any) {
    if (!window.confirm(this.I18n.t('js.text_link_destroy_confirmation'))) {
      event.stopImmediatePropagation();
      event.preventDefault();
      return false;
    }
    _.pull(this.resource.workPackageLinks.elements, this.link);
    this.states.forResource(this.resource!).putValue(this.resource);
    this.link.delete().then(() => {
      this.notificationsService.addSuccess('Успешно удалено');
    }).catch((error:any) => {
      this.wpNotificationsService.handleRawError(error, this as any);
      _.concat(this.resource.workPackageLinks.elements, this.link);
    });
    return false;
  }

  startEditLink() {
    this.edit = true;
  }
  cancelEditLink() {
    this.edit = false;
  }
  doneEditLink() {
    this.edit = false;
    this.halResourceService.patch<any>(`api/v3/links/${this.link.id}`,
      {link: this.link.link, name: this.link.name})
      .toPromise()
      .then(() => {
        this.notificationsService.addSuccess('Успешно обновлено');
      }).catch((error) => {
      this.wpNotificationsService.handleRawError(error, this as any);
    });
  }
}
