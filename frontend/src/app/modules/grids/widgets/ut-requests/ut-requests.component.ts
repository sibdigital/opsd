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
  templateUrl: './ut-requests.component.html',
})

export class WidgetUtRequestsComponent extends AbstractWidgetComponent implements OnInit {
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

    let url = `${this.pathHelper.api.v3.apiV3Base}/user_tasks/assigned/${this.currentuser.userId}`;

    this.halResource
      .get<CollectionResource>(url)
      .toPromise()
      .then((collection) => {
        let entriesarray = collection.source as DocumentResource[];
        let entriesarrayforuser = [];
        for (let obj of entriesarray) {
          if (obj.kind == 'Request' || obj.kind =='Response'){
            entriesarrayforuser.push(obj);
          }
        }
        this.entries = entriesarrayforuser;
        this.entriesLoaded = true;
      });
  }

  public link_to_response_or_request(user_task:UserTasksResource) {
    let link = ``;
    if (user_task.kind == 'Request') {
      link = `/user_tasks/new?assigned_to_id=${user_task.user_creator_id}&head_text=Ответ+на+запрос&kind=Response&object_id=${user_task.object_id}&object_type=${user_task.object_type}&project_id=${user_task.project_id}&related_task_id=${user_task.id}`;
    }
    else {
      link = `/user_tasks/${user_task.id}`;
    }
    return link;
  }

  public response_or_request(user_task:UserTasksResource) {
    let text = ``;
    if (user_task.kind == 'Response') {
      text = `Ответ от:`;
    }
    else {
      text = `Запрос от:`;
    }
    return text;
  }

  public user_taskCreator(user_task:UserTasksResource) {
    return `${this.pathHelper.appBasePath}/users/${user_task.user_creator_id}`;
  }
}
