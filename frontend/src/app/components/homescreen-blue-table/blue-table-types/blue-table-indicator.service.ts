import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

export class BlueTableIndicatorService extends BlueTableService {
  private data:any[] = [];
  private data_local:any = {};
  private columns:string[] = ['Республика Бурятия', 'Ответственный', 'I', 'II', 'III', 'IV', 'I', 'II', 'III', 'IV', 'Процент исполнения'];

  public initialize():void {
    this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.work_package_targets_1c.toString())
      .toPromise()
      .then((resources:HalResource) => {
        resources.source.map((el:HalResource) => {
          this.data_local[el.projectId] = this.data_local[el.projectId] || {name: el.name, targets: []};
          this.data_local[el.projectId].targets.push(el);
        });
        // tslint:disable-next-line:forin
        for (let key in this.data_local) {
          this.data.push({_type: 'National Project', name: this.data_local[key].name});
          this.data_local[key].targets.map( (target:HalResource) => {
            this.data.push(target);
          });
        }
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
    if (row._type === 'Target') {
      switch (i) {
        case 0: {
          return row.target;
          break;
        }
        case 1: {
          if (row.otvetstvenniy) {
            return '<a href="' + super.getBasePath() + '/users/' + row.otvetstvenniy.id + '">' + row.otvetstvenniy.fio + '</a>';
          }
          break;
        }
        case 2: {
          return row.quarter1;
          break;
        }
        case 3: {
          return row.quarter2;
          break;
        }
        case 4: {
          return row.quarter3;
          break;
        }
        case 5: {
          return row.quarter4;
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
        if (row._type === 'Target') {
          return 'p20';
        } else {
          return 'p10';
        }
        break;
      }
    }
    return '';
  }
}
