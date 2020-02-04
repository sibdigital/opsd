import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HomescreenProgressBarComponent} from "core-components/homescreen-progress-bar/homescreen-progress-bar.component";

export class BlueTableIndicatorService extends BlueTableService {
  protected columns:string[] = ['Республика Бурятия', 'Ответственный', 'I', 'II', 'III', 'IV', 'I', 'II', 'III', 'IV', 'Процент исполнения', 'Плановые', 'Фактические'];
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
        name: 'homescreen_plan_I',
        header: this.columns[2],
        parent_name:'homescreen_plan'
      },
      {
        name: 'homescreen_plan_II',
        header: this.columns[3],
        parent_name:'homescreen_plan'
      },
      {
        name: 'homescreen_plan_III',
        header: this.columns[4],
        parent_name:'homescreen_plan'
      },
      {
        name: 'homescreen_plan_IIII',
        header: this.columns[5],
        parent_name:'homescreen_plan'
      },
      {
        name: 'homescreen_fact_I',
        header: this.columns[6],
        parent_name:'homescreen_fact'
      },
      {
        name: 'homescreen_fact_II',
        header: this.columns[7],
        parent_name:'homescreen_fact'
      },
      {
        name: 'homescreen_fact_III',
        header: this.columns[8],
        parent_name:'homescreen_fact'
      },
      {
        name: 'homescreen_fact_IIII',
        header: this.columns[9],
        parent_name:'homescreen_fact'
      },
      {
        name: 'homescreen_plan',
        header: this.columns[11],
        children: 4
      },
      {
        name: 'homescreen_fact',
        header: this.columns[12],
        children: 4
      },
      {
        name: 'homescreen_progress',
        header: this.columns[10],
        type: 'custom',
        component: HomescreenProgressBarComponent
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
                let fact:number = target.fact_year_value;
                let goal:number = target.target_year_value;
                data.push({
                  parentId: row.project_id + 'Project',
                  id: target.target_id,
                  homescreen_name: target.name,
                  homescreen_assignee: target.otvetstvenniy ? '<a href="' + super.getBasePath() + '/users/' + target.otvetstvenniy_id + '">' + target.otvetstvenniy + '</a>' : '',
                  homescreen_plan_I: target.target_quarter1_value,
                  homescreen_plan_II: target.target_quarter2_value,
                  homescreen_plan_III: target.target_quarter3_value,
                  homescreen_plan_IIII: target.target_quarter4_value,
                  homescreen_fact_I: target.fact_quarter1_value,
                  homescreen_fact_II: target.fact_quarter2_value,
                  homescreen_fact_III: target.fact_quarter3_value,
                  homescreen_fact_IIII: target.fact_quarter4_value,
                  homescreen_progress: [goal === 0 || fact === 0 ? '0' : (100 * fact / goal).toFixed(1).toString()]
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
