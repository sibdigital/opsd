import {SimpleResourceCollection} from "core-app/modules/common/path-helper/apiv3/path-resources";
import {Apiv3NotificationsPaths} from "core-app/modules/common/path-helper/apiv3/notifications/apiv3-notifications-paths";

export class Apiv3NotificationsesPaths extends SimpleResourceCollection {
  constructor(basePath:string) {
    super(basePath, 'notifications');
  }

  public id(gridId:string | number) {
    return new Apiv3NotificationsPaths(this.path, gridId);
  }
}
