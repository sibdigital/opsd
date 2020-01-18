import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export class BlueTableBudgetService extends BlueTableService {
  protected columns:string[] = ['Республика Бурятия', 'Куратор', 'РП', 'План срок завершения', 'Исполнено', 'Риски исполнения', 'Остаток', 'Риски и проблемы', 'Исполнение бюджета'];
  private data_local:any;
  public table_data:any = [];
  public configs:any = {
    id_field: 'id',
    parent_id_field: 'parentId',
    parent_display_field: 'homescreen_name',
    show_summary_row: false,
    css: { // Optional
      expand_class: 'icon-arrow-right2',
      collapse_class: 'icon-arrow-down1',
    },
    columns: [
      {
        name: 'homescreen_name',
        header: this.columns[0]
      },
      {
        name: 'homescreen_curator',
        header: this.columns[1]
      },
      {
        name: 'homescreen_RP',
        header: this.columns[2]
      },
      {
        name: 'homescreen_due_date',
        header: this.columns[3]
      },
      {
        name: 'homescreen_done',
        header: this.columns[4]
      },
      {
        name: 'homescreen_risks',
        header: this.columns[5]
      },
      {
        name: 'homescreen_left',
        header: this.columns[6]
      },
      {
        name: 'homescreen_problems',
        header: this.columns[7]
      },
      {
        name: 'homescreen_cost',
        header: this.columns[8]
      }
    ]
  };
  private national_project_titles:{ id:number, name:string }[];
  private national_projects:HalResource[];

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {
      let data:any[] = [];
      if (this.national_project_titles[i].id === 0) {
        data.push({
          id: '0National',
          parentId: '0',
          homescreen_name: 'Проекты Республики Бурятия'
        });
        if (this.data_local[0]) {
          this.data_local[0].map((project:ProjectResource) => {
            data.push({
              id: project.project.project_id,
              parentId: '0National',
              homescreen_name: '<a href="' + super.getBasePath() + '/projects/' + project.project.identifier + '/cost_objects">' + project.project.name + '</a>',
              homescreen_curator: '<a href="' + super.getBasePath() + '/users/' + project.curator.id + '">' + project.curator.fio + '</a>',
              homescreen_RP: project.rukovoditel && project.rukovoditel.length !== 0 ? '<a href="' + super.getBasePath() + '/users/' + project.curator.id + '">' + project.curator.fio + '</a>' : '',
              homescreen_due_date: this.format(project.project.due_date),
              homescreen_done: project.spent,
              homescreen_risks: '',
              homescreen_left: project.ostatok,
              homescreen_problems: '',
              homescreen_cost: project.progress
            });
          });
        }
      } else {
        this.national_projects.map((el:HalResource) => {
          if ((el.id === this.national_project_titles[i].id) || (el.parentId && el.parentId === this.national_project_titles[i].id)) {
            data.push({
              id: el.id + el.type,
              parentId: el.parentId + 'National' || 0,
              homescreen_name: el.name
            });
            if (this.data_local[el.id]) {
              this.data_local[el.id].map((project:ProjectResource) => {
                data.push({
                  id: project.project.id,
                  parentId: project.project.federal_project_id ? project.project.federal_project_id + 'Federal' : project.project.national_project_id + 'National',
                  homescreen_name: '<a href="' + super.getBasePath() + '/projects/' + project.project.identifier + '/cost_objects">' + project.project.name + '</a>',
                  homescreen_curator: '<a href="' + super.getBasePath() + '/users/' + project.curator.id + '">' + project.curator.fio + '</a>',
                  homescreen_RP: project.rukovoditel && project.rukovoditel.length !== 0 ? '<a href="' + super.getBasePath() + '/users/' + project.curator.id + '">' + project.curator.fio + '</a>' : '',
                  homescreen_due_date: this.format(project.project.due_date),
                  homescreen_done: project.spent,
                  homescreen_risks: '',
                  homescreen_left: project.ostatok,
                  homescreen_problems: '',
                  homescreen_cost: project.progress
                });
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
