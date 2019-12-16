import {UserTasksResource} from "core-app/modules/hal/resources/user-tasks-resource";
import {AbstractWidgetComponent} from "core-app/modules/grids/widgets/abstract-widget.component";
import {Component, OnInit, SecurityContext} from '@angular/core';
import {DocumentResource} from "../../../../../../../modules/documents/frontend/module/hal/resources/document-resource";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {TimezoneService} from "core-components/datetime/timezone.service";
import {CurrentUserService} from "core-components/user/current-user.service";

@Component({
  templateUrl: './ut-notes.component.html',
})

export class WidgetUtNotesComponent extends AbstractWidgetComponent implements OnInit {
  public entries:UserTasksResource[] = [];
  private entriesLoaded = false;

  constructor(readonly halResource:HalResourceService,
              readonly pathHelper:PathHelperService,
              readonly i18n:I18nService,
              readonly timezone:TimezoneService,
              readonly currentuser:CurrentUserService) {
    super(i18n);
  }

  ngOnInit() {

    let url = `${this.pathHelper.api.v3.apiV3Base}/user_tasks/creator/${this.currentuser.userId}`;

    this.halResource
      .get<CollectionResource>(url)
      .toPromise()
      .then((collection) => {
        let entriesarray = collection.source as DocumentResource[];
        let entriesarrayforuser = [];
        for (let obj of entriesarray) {
          if (obj.kind == 'Note'){
            entriesarrayforuser.push(obj);
          }
        }
        this.entries = entriesarrayforuser;
        this.entriesLoaded = true;
      });
  }

  public user_taskText(user_task:UserTasksResource) {
    return `${this.pathHelper.appBasePath}/user_tasks/${user_task.id}`;
  }

  public newNotePath() {
    return `${this.pathHelper.appBasePath}/user_tasks/new?head_text=Новая+заметка&kind=Note`;
  }
}
