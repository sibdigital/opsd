import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export class BlueTableBudgetService extends BlueTableService {
  protected columns:string[] = ['Республика Бурятия', 'Куратор', 'РП', 'План срок завершения', 'Исполнено', 'Риски исполнения', 'Остаток', 'Риски и проблемы', 'Исполнение бюджета'];
  private data_local:any;
  private national_project_titles:{ id:number, name:string }[];
  private national_projects:HalResource[];

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {
      let data:any[] = [];
      if (this.national_project_titles[i].id === 0) {
        data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
        if (this.data_local[0]) {
          this.data_local[0].map((project:ProjectResource) => {
            data.push(project);
          });
        }
      } else {
        this.national_projects.map((el:HalResource) => {
          if ((el.id === this.national_project_titles[i].id) || (el.parentId && el.parentId === this.national_project_titles[i].id)) {
            data.push(el);
            if (this.data_local[el.id]) {
              this.data_local[el.id].map((project:ProjectResource) => {
                data.push(project);
              });
            }
          }
        });
      }
      resolve(data);
    });
  }
  public getPages():number {
    return this.national_project_titles.length;
  }
  public initializeAndGetData():Promise<any[]> {
    return new Promise((resolve) => {
      let data_local:any = {};
      this.national_project_titles = [];
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          this.national_projects = resources.elements;
          this.national_projects.map((el:HalResource) => {
            if (!el.parentId) {
              this.national_project_titles.push({id: el.id, name: el.name});
            }
          });
          this.national_project_titles.push({id: 0, name: 'Проекты Республики Бурятия'});
          this.halResourceService
            .get<HalResource>(this.pathHelper.api.v3.summary_budgets_users.toString())
            .toPromise()
            .then((response:HalResource) => {
              response.source.map((budget:HalResource) => {
                budget['_type'] = 'Budget';
                if (!budget.project.national_project_id) {
                  budget.project.national_project_id = 0;
                }
                if (!budget.project.federal_project_id) {
                  budget.project.federal_project_id = 0;
                }
                if ((budget.project.federal_project_id !== 0) || (budget.project.federal_project_id === 0 && budget.project.national_project_id === 0)) {
                  data_local[budget.project.federal_project_id] = data_local[budget.project.federal_project_id] || [];
                  data_local[budget.project.federal_project_id].push(budget);
                } else {
                  data_local[budget.project.national_project_id] = data_local[budget.project.national_project_id] || [];
                  data_local[budget.project.national_project_id].push(budget);
                }
              });
              this.data_local = data_local;
              this.getDataFromPage(0).then(data => {
                resolve(data);
              });
            });
        });
    });
  }

  public getTdData(row:any, i:number):string {
    if (row._type === 'Budget') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.project.identifier + '/cost_objects">' + row.project.name + '</a>';
          break;
        }
        case 1: {
          if (row.curator && row.curator.length !== 0) {
            return '<a href="' + super.getBasePath() + '/users/' + row.curator.id + '">' + row.curator.fio + '</a>';
          }
          break;
        }
        case 2: {
          if (row.rukovoditel && row.rukovoditel.length !== 0) {
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

  public pagesToText(i:number):string {
    return this.national_project_titles[i].name;
  }
}
