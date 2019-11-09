import {UserTasksResource} from "core-app/modules/hal/resources/user-tasks-resource";
import {AbstractWidgetComponent} from "core-app/modules/grids/widgets/abstract-widget.component";
import {Component, OnInit, SecurityContext} from '@angular/core';
import {DocumentResource} from "../../../../../../../modules/documents/frontend/module/hal/resources/document-resource";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {TimezoneService} from "core-components/datetime/timezone.service";
import {CurrentUserService} from "core-components/user/current-user.service";
import {ChartOptions, ChartType, ChartDataSets} from 'chart.js';

@Component({
  templateUrl: './ut-my-tasks.component.html',
})

export class WidgetUtMyTasksComponent extends AbstractWidgetComponent implements OnInit {
  public entries:UserTasksResource[] = [];
  public dateBegin:string;
  public dateEnd:string;
  public dateCheck:boolean = false;
  private entriesLoaded = false;

  constructor(readonly i18n:I18nService,
              readonly timezoneService:TimezoneService,
              readonly currentuser:CurrentUserService,
              protected pathHelper:PathHelperService,
              protected halResourceService:HalResourceService) {
    super(i18n);
  }

  ngOnInit() {
    let url = `${this.pathHelper.api.v3.apiV3Base}/user_tasks/assigned/${this.currentuser.userId}`;
    this.halResourceService
      .get<HalResource>(url)
      .toPromise()
      .then((resource:HalResource) => {
        let entriesarray = resource.source as DocumentResource[];
        let entriesarrayforuser = [];
        for (var obj of entriesarray) {
          if (obj.kind == 'Task') {
              entriesarrayforuser.push(obj);
          }
        }
        this.entries = entriesarrayforuser;
        this.entriesLoaded = true;
      });
  }

  public filterChart() {
    let url = `${this.pathHelper.api.v3.apiV3Base}/user_tasks/assigned/${this.currentuser.userId}`;
    this.halResourceService
      .get<HalResource>(url, this.getParams())
      .toPromise()
      .then((resource:HalResource) => {
        this.dateBegin = this.parser(resource.dateBegin);
        this.dateEnd =  this.parser(resource.dateEnd);
        this.dateCheck = (resource.dateCheck);
        let entriesarray = resource.source as DocumentResource[];
        let entriesarrayforuser = [];
        if (resource.dateCheck ==true) {
          for (var obj of entriesarray) {
            if (obj.kind == 'Task' && Date.parse(obj.due_date) >= Date.parse(resource.dateBegin) && Date.parse(obj.due_date) <= Date.parse(resource.dateEnd)) {
              entriesarrayforuser.push(obj);
            }
          }
        }
        else {
          for (var obj of entriesarray) {
            if (obj.kind == 'Task') {
              entriesarrayforuser.push(obj);
            }
          }
        }
        this.entries = entriesarrayforuser;
        this.entriesLoaded = true;
      });
  }

  public user_taskResponse(user_task:UserTasksResource) {
    return `/user_tasks/new?assigned_to_id=${user_task.assigned_to_id}&head_text=Ответ+по+задаче&kind=Response&object_id=${user_task.object_id}&object_type=${user_task.object_type}&project_id=${user_task.project_id}&related_task_id=${user_task.id}`;
  }

  public user_taskCreator(user_task:UserTasksResource) {
    return `${this.pathHelper.appBasePath}/users/${user_task.user_creator_id}`;
  }

  public formatter(data:any) {
    if (moment(data, 'YYYY-MM-DD', true).isValid()) {
      var d = this.timezoneService.parseDate(data);
      return this.timezoneService.formattedISODate(d);
    } else {
      return null;
    }
  }

  public parser(data:any) {
    if (moment(data, 'YYYY-MM-DD', true).isValid()) {
      return data;
    } else {
      return null;
    }
  }

  private getParams():any {
    let params:any = {};
    params['dateCheck'] = this.dateCheck;
    params['dateBegin'] = this.dateBegin;
    params['dateEnd'] = this.dateEnd;
    return params;
  }
}
