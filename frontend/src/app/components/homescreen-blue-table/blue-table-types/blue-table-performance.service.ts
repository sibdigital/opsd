import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";

export class BlueTablePerformanceService extends BlueTableService {
  protected columns:string[] = ['Показатель', 'Значение'];
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
        name: 'homescreen_value',
        header: this.columns[1]
      }
    ]
  };
  public initializeAndGetData():Promise<any[]> {
    return new Promise((resolve) => {
      let data:any[] = [];
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.head_performances.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          resources.elements.map((el:HalResource) => {
            data.push({
              id: el.id,
              parentId: 0,
              homescreen_name: el.sortCode + '. ' + el.name,
              homescreen_value: el.value
            });
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
