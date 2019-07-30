import {Injectable} from '@angular/core';
import {AbstractDmService} from "core-app/modules/hal/dm-services/abstract-dm.service";
import {NotificationsResource} from "core-app/modules/hal/resources/notifications-resource";

@Injectable()
export class NotificationsDmService extends AbstractDmService<NotificationsResource> {
  protected listUrl() {
    return this.pathHelper.api.v3.notifications.toString();
  }

  protected oneUrl(id:number|string) {
    return this.pathHelper.api.v3.notifications.id(id).toString();
  }
}
