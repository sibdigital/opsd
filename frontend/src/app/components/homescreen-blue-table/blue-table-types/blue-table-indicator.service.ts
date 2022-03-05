import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HomescreenProgressBarComponent} from "core-components/homescreen-progress-bar/homescreen-progress-bar.component";

export class BlueTableIndicatorService extends BlueTableService {
  private today = new Date();
  protected columns:string[] = ['Наименование', 'Ответственный', 'Базовое значение',
    'Плановое значение ' + String(this.today.getFullYear() - 1), 'Фактическое значение ' + String(this.today.getFullYear() - 1),
    'Плановое значение ' + String(this.today.getFullYear()), 'Фактическое значение ' + String(this.today.getFullYear()),
    'Плановое значение ' + String(this.today.getFullYear() + 1), 'Фактическое значение ' + String(this.today.getFullYear() + 1),
    'Процент исполнения', 'Единица измерения'];
  private data_local:any;
  private national_project_titles:{ id:number, name:string }[];
  private national_projects:HalResource[];
  public table_data:any = [];
  public configs:any = {
    id_field: 'id',
    parent_id_field: 'parentId',
    parent_display_field: 'homescreen_name',
    show_summary_row: false,
    subheaders: true,
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
        name: 'homescreen_assignee',
        header: this.columns[1]
      },
      {
        name: 'homescreen_base',
        header: this.columns[2]
      },
      {
        name: 'homescreen_plan_prev',
        header: this.columns[3]
      },
      {
        name: 'homescreen_fact_prev',
        header: this.columns[4]
      },
      {
        name: 'homescreen_plan_now_I',
        header: 'I кв.',
        parent_name:'homescreen_plan_now'
      },
      {
        name: 'homescreen_plan_now_II',
        header: 'II кв.',
        parent_name:'homescreen_plan_now'
      },
      {
        name: 'homescreen_plan_now_III',
        header: 'III кв.',
        parent_name:'homescreen_plan_now'
      },
      {
        name: 'homescreen_plan_now_IV',
        header: 'IV кв.',
        parent_name:'homescreen_plan_now'
      },
      {
        name: 'homescreen_fact_now_I',
        header: 'I кв.',
        parent_name:'homescreen_fact_now'
      },
      {
        name: 'homescreen_fact_now_II',
        header: 'II кв.',
        parent_name:'homescreen_fact_now'
      },
      {
        name: 'homescreen_fact_now_III',
        header: 'III кв.',
        parent_name:'homescreen_fact_now'
      },
      {
        name: 'homescreen_fact_now_IV',
        header: 'IV кв.',
        parent_name:'homescreen_fact_now'
      },
      {
        name: 'homescreen_plan_next_I',
        header: 'I кв.',
        parent_name:'homescreen_plan_next'
      },
      {
        name: 'homescreen_plan_next_II',
        header: 'II кв.',
        parent_name:'homescreen_plan_next'
      },
      {
        name: 'homescreen_plan_next_III',
        header: 'III кв.',
        parent_name:'homescreen_plan_next'
      },
      {
        name: 'homescreen_plan_next_IV',
        header: 'IV кв.',
        parent_name:'homescreen_plan_next'
      },
      {
        name: 'homescreen_fact_next_I',
        header: 'I кв.',
        parent_name:'homescreen_fact_next'
      },
      {
        name: 'homescreen_fact_next_II',
        header: 'II кв.',
        parent_name:'homescreen_fact_next'
      },
      {
        name: 'homescreen_fact_next_III',
        header: 'III кв.',
        parent_name:'homescreen_fact_next'
      },
      {
        name: 'homescreen_fact_next_IV',
        header: 'IV кв.',
        parent_name:'homescreen_fact_next'
      },
      {
        name: 'homescreen_plan_now',
        header: this.columns[5],
        children: 4
      },
      {
        name: 'homescreen_fact_now',
        header: this.columns[6],
        children: 4
      },
      {
        name: 'homescreen_plan_next',
        header: this.columns[7],
        children: 4
      },
      {
        name: 'homescreen_fact_next',
        header: this.columns[8],
        children: 4
      },
      {
        name: 'homescreen_progress',
        header: this.columns[9],
        type: 'custom',
        component: HomescreenProgressBarComponent
      },
      {
        name: 'homescreen_units',
        header: this.columns[10]
      }
    ]
  };

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {
      let data:any[] = [];
      this.national_projects.map((el:HalResource) => {
        if ((el.id === this.national_project_titles[i].id) || (el.parentId && el.parentId === this.national_project_titles[i].id)) {
          data.push({
            id: el.id + el.type,
            parentId: el.parentId + 'National' || 0,
            homescreen_name: el.name
          });
          if (this.data_local[el.id]) {
            this.data_local[el.id].map((row:HalResource) => {
              data.push({_type: row._type, name: row.name, identifier: row.identifier});
              data.push({
                id: row.project_id + 'Project',
                parentId: !row.federal_id ? row.parentId + el.type : row.parentId + 'Federal',
                homescreen_name: '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>'
              });
              row.targets.map((target:HalResource) => {
                let fact:number = target.fact_now;
                let goal:number = target.target_now;

                let i:number = target.target_current_year_fact.length;
                while (i !== 0) {
                  if (target.target_current_year_fact[i - 1] !== 0) {
                    goal = target.target_current_year_plan[3];
                    fact = target.target_current_year_fact[i - 1];
                    break;
                  }
                  else {goal = 0; fact = 0; }
                  i--;
                }

                data.push({
                  parentId: row.project_id + 'Project',
                  id: target.target_id,
                  homescreen_name: target.name,
                  homescreen_assignee: target.otvetstvenniy ? '<a href="' + super.getBasePath() + '/users/' + target.otvetstvenniy_id + '">' + target.otvetstvenniy + '</a>' : '',
                  homescreen_plan_prev: target.target_prev_year_plan,
                  homescreen_fact_prev: target.target_prev_year_fact,
                  homescreen_plan_now_I: target.target_current_year_plan[0],
                  homescreen_plan_now_II: target.target_current_year_plan[1],
                  homescreen_plan_now_III: target.target_current_year_plan[2],
                  homescreen_plan_now_IV: target.target_current_year_plan[3],
                  homescreen_fact_now_I: target.target_current_year_fact[0],
                  homescreen_fact_now_II: target.target_current_year_fact[1],
                  homescreen_fact_now_III: target.target_current_year_fact[2],
                  homescreen_fact_now_IV: target.target_current_year_fact[3],
                  homescreen_plan_next_I: target.target_next_year_plan[0],
                  homescreen_plan_next_II: target.target_next_year_plan[1],
                  homescreen_plan_next_III: target.target_next_year_plan[2],
                  homescreen_plan_next_IV: target.target_next_year_plan[3],
                  homescreen_fact_next_I: target.target_next_year_fact[0],
                  homescreen_fact_next_II: target.target_next_year_fact[1],
                  homescreen_fact_next_III: target.target_next_year_fact[2],
                  homescreen_fact_next_IV: target.target_next_year_fact[3],
                  homescreen_progress: [!!goal ? (100 * fact / goal).toFixed(1).toString() : '0.0' ],
                  homescreen_units: target.unit,
                  homescreen_base: target.basic_value
                });
              });
            });
          }
        }
      });
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
          this.halResourceService
            .get<HalResource>(this.pathHelper.api.v3.plan_fact_quarterly_target_values_view.toString())
            .toPromise()
            .then((targets:HalResource) => {
              targets.source.map((el:HalResource) => {
                if ((el.federal_id !== 0) || (el.federal_id === 0 && el.national_id === 0)) {
                  data_local[el.federal_id] = data_local[el.federal_id] || [];
                  data_local[el.federal_id].push(el);
                } else {
                  data_local[el.national_id] = data_local[el.national_id] || [];
                  data_local[el.national_id].push(el);
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
    if (row._type === 'PlanFactQuarterlyTargetValue') {
      switch (i) {
        case 0: {
          return row.name;
          break;
        }
        case 1: {
          if (row.otvetstvenniy) {
            return '<a href="' + super.getBasePath() + '/users/' + row.otvetstvenniy_id + '">' + row.otvetstvenniy + '</a>';
          }
          break;
        }
        case 2: {
          return row.target_quarter1_value;
          break;
        }
        case 3: {
          return row.target_quarter2_value;
          break;
        }
        case 4: {
          return row.target_quarter3_value;
          break;
        }
        case 5: {
          return row.target_quarter4_value;
          break;
        }
        case 6: {
          return row.fact_quarter1_value;
          break;
        }
        case 7: {
          return row.fact_quarter2_value;
          break;
        }
        case 8: {
          return row.fact_quarter3_value;
          break;
        }
        case 9: {
          return row.fact_quarter4_value;
          break;
        }
        case 10: {
          let fact:number = row.fact_year_value;
          let target:number = row.target_year_value;
          return target === 0 ? '0' : (100 * fact / target).toFixed();
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
    if (row._type === 'Project') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>';
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
        if (row._type === 'PlanFactQuarterlyTargetValue') {
          return 'p40';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
      case 10: {
        if (row._type === 'WorkPackageTarget1C') {
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
