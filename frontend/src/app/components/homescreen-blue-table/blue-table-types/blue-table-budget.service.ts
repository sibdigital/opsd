import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

export class BlueTableBudgetService extends BlueTableService {
  private data:any[] = [];
  private promises:Promise<CollectionResource<HalResource>>[] = [];
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
              this.data_local[budget.project.id] = budget;
            });
            resources.elements.map( (national:HalResource) => {
              this.data.push(national);
              if (national.projects) {
                national.projects.map((project:HalResource) => {
                  if (this.data_local[project['id']]) {
                    let b = this.data_local[project['id']];
                    b['_type'] = 'Budget';
                    b['curator'] = project['curator'];
                    b['rukovoditel'] = project['rukovoditel'];
                    this.data.push(b);
                  }
                });
              }
            });
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
          return row.project.due_date;
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
    if (row._type === 'National Project') {
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
        if (row._type === 'Budget') {
          return 'budget';
        }
        return row.parentId == null ? 'parent' : 'child';
        break;
      }
    }
    return '';
  }
}
