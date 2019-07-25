import {Component, OnInit} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

@Component({
  selector: 'homescreen-blue-table',
  templateUrl: './homescreen-blue-table.html',
  styleUrls: ['./homescreen-blue-table.sass']
})
export class HomescreenBlueTableComponent implements OnInit {
  public columns:string[] = ['Проект', 'Куратор/\nРП', 'План срок завершения', 'Предстоящие мероприятия', 'Просроченные мероприятия/\nПроблемы', 'Прогресс/\nИсполнение бюджета', 'KPI'];
  public data:any[] = [];
  public readonly appBasePath:string;

  constructor(protected I18n:I18nService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        resources.elements.map((el:HalResource) => {
          this.data.push(el);
          if (el.projects) {
            el.projects.map( (project:ProjectResource) => {
              project['_type'] = 'Project';
              this.data.push(project);
            });
          }
        });
      });
  }

  public getClass(row:any):string {
    if (row._type === 'Project') {
      return 'project';
    }
    return row.parentId == null ? 'parent' : 'child';
  }

  public getProjectHref(row:any):string {
    return this.appBasePath + '/projects/' + row.identifier;
  }
}
