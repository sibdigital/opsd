import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export class BlueTableIndicatorService extends BlueTableService {
  protected columns:string[] = ['Республика Бурятия', 'Ответственный', 'I', 'II', 'III', 'IV', 'I', 'II', 'III', 'IV', 'Процент исполнения'];
  private data_local:any;
  private national_project_titles:{ id:number, name:string }[];
  private national_projects:HalResource[];

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {
      let data:any[] = [];
      if (this.national_project_titles[i].id === 0) {
        data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
        if (this.data_local[0]) {
          this.data_local[0].map((row:HalResource) => {
            data.push({_type: row._type, name: row.name, identifier: row.identifier});
            row.targets.map((target:HalResource) => {
              data.push(target);
            });
          });
        }
      } else {
        this.national_projects.map((el:HalResource) => {
          if ((el.id === this.national_project_titles[i].id) || (el.parentId && el.parentId === this.national_project_titles[i].id)) {
            data.push(el);
            if (this.data_local[el.id]) {
              this.data_local[el.id].map((row:HalResource) => {
                data.push({_type: row._type, name: row.name, identifier: row.identifier});
                row.targets.map((target:HalResource) => {
                  data.push(target);
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
            return '<a href="' + super.getBasePath() + '/users/' + row.otvetstvenniy.id + '">' + row.otvetstvenniy.lastname + ' ' + row.otvetstvenniy.firstname.slice(0, 1) + '.' + row.otvetstvenniy.patronymic.slice(0, 1) + '.</a>';
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
