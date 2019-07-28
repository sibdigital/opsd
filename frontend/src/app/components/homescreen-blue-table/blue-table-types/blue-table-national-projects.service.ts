import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {OnInit} from "@angular/core";

export class BlueTableNationalProjectsService extends BlueTableService {
  private data:any[] = [];
  private columns:string[] = ['Проект', 'Куратор/\nРП', 'План срок завершения', 'Предстоящие мероприятия', 'Просроченные мероприятия/\nПроблемы', 'Прогресс/\nИсполнение бюджета', 'KPI'];

  public initialize():void {
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
  public getColumns():string[] {
    return this.columns;
  }
  public getPages():number {
    return 0;
  }

  public getData():any[] {
    return this.data;
  }

  public getTdData(row:any, i:number):string {
    if (row._type === 'Project') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>';
          break;
        }
        case 1: {
          let fio1:string = row.curator ? row.curator.fio :'';
          let fio2:string = row.rukovoditel ? row.rukovoditel.fio :'';
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + fio1 + '</a><br>' +
            '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + fio2 + '</a>';
          break;
        }
        case 2: {
          let duedate:string = row.dueDate ? row.dueDate.due_date :'';
          return '<a href="' + super.getBasePath() + '/projects/' + duedate + '</a>';
          break;
        }
        case 3: {
          let count:string = row.upcomingTasksCount ? row.upcomingTasksCount.count :'';
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + count + '</a>';
          break;
        }
        case 4: {
          let count1:string = row.dueMilestoneCount ? row.dueMilestoneCount.count :'';
          let count2:string = row.problemCount ? row.problemCount.count :'';
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + count1 + '</a><br>' +
            '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + count2 + '</a>';
          break;
        }
        case 5: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.doneRatio + '</a>';
          break;
        }
        case 6: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">Посмотреть</a>';
          break;
        }
      }
    } else {
      switch (i) {
        case 0: {
          return row.name;
          break;
        }
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
