import {
  SimpleResource
} from 'core-app/modules/common/path-helper/apiv3/path-resources';

export class Apiv3NotificationsPaths extends SimpleResource {
  constructor(basePath:string, notificationsId:string|number) {
    super(basePath, notificationsId);
  }
}
