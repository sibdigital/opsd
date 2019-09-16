import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

export class BlueTableBudgetService extends BlueTableService {
  private data:any[] = [];
  private data_local:any = {};
  private columns:string[] = ['Республика Бурятия', 'Куратор', 'РП', 'План срок завершения', 'Исполнено', 'Риски исполнения', 'Остаток', 'Риски и проблемы', 'Исполнение бюджета'];

  public initialize():void {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        this.halResourceService
          .get<HalResource>(this.pathHelper.api.v3.summary_budgets_users.toString())
          .toPromise()
          .then((response:HalResource) => {
            response.source.map((budget:HalResource) => {
              budget['_type'] = 'Budget';
              if (budget.project.federal_project_id) {
                this.data_local[budget.project.federal_project_id] = this.data_local[budget.project.federal_project_id] || [];
                this.data_local[budget.project.federal_project_id].push(budget);
              } else {
                this.data_local[0] = this.data_local[0] || [];
                this.data_local[0].push(budget);
              }
            });
            resources.elements.map( (el:HalResource) => {
              this.data.push(el);
              if (this.data_local[el.id]) {
                this.data_local[el.id].map( (budget:ProjectResource) => {
                  this.data.push(budget);
                });
              }
            });
            this.data.push({_type: 'NationalProject', id:0, name: 'Проекты Республики Бурятия'});
            if (this.data_local[0]) {
              this.data_local[0].map( (budget:ProjectResource) => {
                this.data.push(budget);
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
    if (row._type === 'Budget') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.project.identifier + '">' + row.project.name + '</a>';
          break;
        }
        case 1: {
          if (row.curator) {
            return '<a href="' + super.getBasePath() + '/users/' + row.curator.id + '">' + row.curator.fio + '</a>';
          }
          break;
        }
        case 2: {
          if (row.rukovoditel) {
            return '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel.id + '">' + row.rukovoditel.fio + '</a>';
          }
          break;
        }
        case 3: {
          return this.format(row.project.due_date);
          break;
        }
        case 4: {
          return row.spent;
          break;
        }
        case 6: {
          return row.ostatok;
          break;
        }
        case 8: {
          return row.progress;
          break;
        }
      }
    }
    if (row._type === 'NationalProject') {
      switch (i) {
        case 0: {
          return row.name;
          break;
        }
      }
    }
    return '';
  }

  public format(input:string):string {
    if (input) {
      return input.slice(3, 5) + '.' + input.slice(0, 2) + '.' + input.slice(6, 10);
    } else {
      return '';
    }
  }

  public getTdClass(row:any, i:number):string {
    switch (i) {
      case 0: {
        if (row._type === 'Budget') {
          return 'p30';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
    }
    return '';
  }
}
