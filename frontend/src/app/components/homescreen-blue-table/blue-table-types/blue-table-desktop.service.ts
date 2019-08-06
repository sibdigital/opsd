import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";

export class BlueTableDesktopService extends BlueTableService {
  private data:any[] = [];
  private columns:string[] = ['Проект', 'Куратор/\nРП', 'План срок завершения', 'Предстоящие мероприятия', 'Просроченные кт/\nПроблемы', 'Прогресс/\nИсполнение бюджета', 'KPI'];
  private national_project_titles:{id:number, name:string}[] = [];

  public initialize():void {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        resources.elements.map((el:HalResource) => {
          if (!el.parentId) {
            this.national_project_titles.push({id: el.id, name: el.name});
          }
        });
        this.national_project_titles.push({id:0, name: 'Проекты Республики Бурятия'});
      });
  }

  public getDataFromPage(i:number):any[] {
    this.data = [];
    if (this.national_project_titles[i].id === 0) {
      let filters = new ApiV3FilterBuilder();
      filters.add('national_project_id', '!*', []);
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects.toString(),  {"filters": filters.toJson()})
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          this.data.push({_type:"National Project", name:"Проекты Республики Бурятия", parentId:null});
          resources.elements.map((el:HalResource) => {
            this.data.push(el);
          });
        });
    } else {
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          resources.elements.map((el:HalResource) => {
            if ((el.id === this.national_project_titles[i].id) || (el.parentId && el.parentId === this.national_project_titles[i].id)) {
              this.data.push(el);
              if (el.projects) {
                el.projects.map( (project:ProjectResource) => {
                  project['_type'] = 'Project';
                  this.data.push(project);
                });
              }
            }
          });
        });
    }
    return this.data;
  }
  public getColumns():string[] {
    return this.columns;
  }
  public getPages():number {
    return this.national_project_titles.length - 2;
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
          let result:string = '';
          if (row.curator) {
            result += '<a href="' + super.getBasePath() + '/users/' + row.curator.id + '">' + row.curator.fio + '</a>';
          }
          result += '<br>';
          if (row.rukovoditel) {
            result += '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel.id + '">' + row.rukovoditel.fio + '</a>';
          }
          return result;
          break;
        }
        case 2: {
          return row.dueDate ? this.format(row.dueDate.due_date) :'';
          break;
        }
        case 3: {
          if (row.upcomingTasksCount) {
            return '<a href=\'' + super.getBasePath() + '/projects/' + row.identifier +
              '/work_packages?plan_type=execution&query_id=3&query_props=%7B"c"%3A%5B"id"%2C"subject"%2C"type"%2C"status"%2C"assignee"%5D%2C"hl"%3A"none"%2C"hi"%3Afalse%2C"g"%3A""%2C"t"%3A""%2C"f"%3A%5B%7B"n"%3A"status"%2C"o"%3A"o"%2C"v"%3A%5B%5D%7D%2C%7B"n"%3A"type"%2C"o"%3A"%3D"%2C"v"%3A%5B"1"%5D%7D%2C%7B"n"%3A"planType"%2C"o"%3A"~"%2C"v"%3A%5B"execution"%5D%7D%2C%7B"n"%3A"dueDate"%2C"o"%3A">t%2B"%2C"v"%3A%5B"0"%5D%7D%2C%7B"n"%3A"planType"%2C"o"%3A"~"%2C"v"%3A%5B"execution"%5D%7D%5D%2C"pa"%3A1%2C"pp"%3A20%7D\'>' + row.upcomingTasksCount.count + '</a>';
          }
          break;
        }
        case 4: {
          let count1:string = row.dueMilestoneCount ? row.dueMilestoneCount.count :'';
          let count2:string = row.problemCount ? row.problemCount.count :'';
          return '<a href=\'' + super.getBasePath() + '/projects/' + row.identifier +
            '/work_packages?plan_type=execution&query_id=5&query_props=%7B"c"%3A%5B"id"%2C"type"%2C"status"%2C"subject"%2C"startDate"%2C"dueDate"%5D%2C"tv"%3Atrue%2C"tzl"%3A"days"%2C"hl"%3A"none"%2C"hi"%3Afalse%2C"g"%3A""%2C"t"%3A"id%3Aasc"%2C"f"%3A%5B%7B"n"%3A"status"%2C"o"%3A"o"%2C"v"%3A%5B%5D%7D%2C%7B"n"%3A"type"%2C"o"%3A"%3D"%2C"v"%3A%5B"2"%5D%7D%2C%7B"n"%3A"planType"%2C"o"%3A"~"%2C"v"%3A%5B"execution"%5D%7D%2C%7B"n"%3A"dueDate"%2C"o"%3A"<t-"%2C"v"%3A%5B"0"%5D%7D%2C%7B"n"%3A"planType"%2C"o"%3A"~"%2C"v"%3A%5B"execution"%5D%7D%2C%7B"n"%3A"planType"%2C"o"%3A"~"%2C"v"%3A%5B"execution"%5D%7D%5D%2C"pa"%3A1%2C"pp"%3A20%7D\'>' + count1 + '</a>&nbsp;/&nbsp;' +
            '<a href="' + super.getBasePath() + '/vkladka1/problems">' + count2 + '</a>';
          break;
        }
        case 5: {
          return row.doneRatio;
          break;
        }
        case 6: {
          return '<a href="' + super.getBasePath() + '/vkladka1/kpi">Посмотреть</a>';
          break;
        }
        case 100: {
          return row.budgetFraction;
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
          return 'p30';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
      case 5: {
        if (row._type === 'Project') {
          return 'progressbar';
        }
        break;
      }
    }
    return '';
  }

  public format(input:string):string {
    return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
  }

  public pagesToText(i:number):string {
    return this.national_project_titles[i].name;
  }
}
