import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";

export class BlueTableKtService extends BlueTableService {
  private data:any[];
  private columns:string[] = ['№ п/п', 'Мероприятие', 'Отв. Исполнитель', 'Срок выполнения', 'Статус', 'Факт. выполнение', 'Проблемы'];

  public getColumns():string[] {
    return this.columns;
  }
  public getData(param?:any):any[] {
    this.data = [];
    this.halResourceService
      .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(param).queries.default.toString())
      .toPromise()
      .then((resources:QueryResource) => {
        resources.results.elements.map((el:HalResource) => {
          this.data.push(el);
        });
      });
    return this.data;
  }

  public getTdData(row:any, i:number):string {
    switch (i) {
      case 0: {
        return row.id;
        break;
      }
      case 1: {
        return row.name;
        break;
      }
      case 2: {
        return row.assignee ? row.assignee.$links.self.title :'';
        break;
      }
      case 3: {
        return row.dueDate;
        break;
      }
      case 4: {
        return row.status ? row.status.$links.self.title :'';
        break;
      }
    }
    return '';
  }

  public getTdClass(row:any, i:number):string {
    return '';
  }
}
