import {AbstractWidgetComponent} from "core-app/modules/grids/widgets/abstract-widget.component";
import {Component, OnInit} from '@angular/core';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {TimezoneService} from "core-components/datetime/timezone.service";
import {NotificationsResource} from "core-app/modules/hal/resources/notifications-resource";
import {UserCacheService} from "core-components/user/user-cache.service";
import {UserResource} from "core-app/modules/hal/resources/user-resource";
import {NotificationsDmService} from "core-app/modules/hal/dm-services/notifications-dm.service";

@Component({
  templateUrl: './notifications.component.html',
})
export class WidgetNotificationsComponent extends AbstractWidgetComponent implements OnInit {
  public text = {
    title: this.i18n.t('js.grid.widgets.notifications.title'),
    createdBy: this.i18n.t('js.label_created_by'),
    at: this.i18n.t('js.grid.widgets.notifications.at'),
    noResults: this.i18n.t('js.grid.widgets.notifications.no_results'),
  };

  public entries:NotificationsResource[] = [];
  private entriesLoaded = false;

  constructor(readonly halResource:HalResourceService,
              readonly pathHelper:PathHelperService,
              readonly i18n:I18nService,
              readonly timezone:TimezoneService,
              readonly userCache:UserCacheService,
              readonly notificationsDm:NotificationsDmService) {
    super(i18n);
  }

  ngOnInit() {
    this.notificationsDm
      .list({ sortBy: [['alert_date', 'desc']], pageSize: 3 })
      .then((collection) => {
        this.entries = collection.elements as NotificationsResource[];
        this.entriesLoaded = true;

        this.entries.forEach((entry) => {
          if (!entry.created_by) {
            return;
          }

          this.userCache
            .require(entry.created_by.idFromLink)
            .then((user:UserResource) => {
              entry.created_by = user;
            });
        });
      });
  }

  public notificationsPath(notifications:NotificationsResource) {
    return `${this.pathHelper.appBasePath}/notifications/${notifications.id}`;
  }

  public notificationsProjectPath(notifications:NotificationsResource) {
    return this.pathHelper.projectPath(notifications.project.idFromLink);
  }

  public notificationsProjectName(notifications:NotificationsResource) {
    return notifications.project.name;
  }

  public notificationsAuthorName(notifications:NotificationsResource) {
    return notifications.author.name;
  }

  public notificationsAuthorPath(notifications:NotificationsResource) {
    return this.pathHelper.userPath(notifications.author.id);
  }

  public notificationsAuthorAvatar(notifications:NotificationsResource) {
    return notifications.author.avatar;
  }

  public notificationsCreated(notifications:NotificationsResource) {
    return this.timezone.formattedDatetime(notifications.createdAt);
  }

  public get noEntries() {
    return !this.entries.length && this.entriesLoaded;
  }
}
