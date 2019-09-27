import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";

export class BlueTablePerformanceService extends BlueTableService {
  protected columns:string[] = ['Показатель', 'Значение'];

  public initializeAndGetData():Promise<any[]> {
    return new Promise((resolve) => {
      let data:any[] = [];
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.head_performances.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          resources.elements.map((el:HalResource) => {
            data.push(el);
          });
          resolve(data);
        });
    });
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
