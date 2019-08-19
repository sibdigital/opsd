import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";

export class BlueTablePerformanceService extends BlueTableService {
  private data:any[] = [];
  private columns:string[] = ['Показатель', 'Значение'];

  public initialize():void {
    this.data = [];
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.head_performances.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        resources.elements.map((el:HalResource) => {
          this.data.push(el);
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
    switch (i) {
      case 0: {
        return row.sortCode + '. ' + row.name;
        break;
      }
      case 1: {
        return row.value;
        break;
      }
    }
    return '';
  }

  public getTdClass(row:any, i:number):string {
    switch (i) {
      case 0: {
        return 'performance';
        break;
      }
    }
    return '';
  }
}
