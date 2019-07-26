import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

export class BlueTableNationalProjectsService extends BlueTableService {
  private data:any[];
  private columns:string[] = ['Проект', 'Куратор/\nРП', 'План срок завершения', 'Предстоящие мероприятия', 'Просроченные мероприятия/\nПроблемы', 'Прогресс/\nИсполнение бюджета', 'KPI'];

  public getColumns():string[] {
    return this.columns;
  }

  public getData(param?:any):any[] {
    this.data = [];
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
    return this.data;
  }

  public getTdData(row:any, i:number):string {
    switch (i) {
      case 0: {
        if (row._type !== 'Project') {
          return row.name;
        } else {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>';
        }
        break;
      }
    }
    return '';
  }

  public getTdClass(row:any, i:number):string {
    switch (i) {
      case 0: {
        if (row._type === 'Project') {
          return 'project';
        }
        return row.parentId == null ? 'parent' : 'child';
        break;
      }
    }
    return '';
  }
}
