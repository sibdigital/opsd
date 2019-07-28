import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";

export class BlueTableProblemsService extends BlueTableService {
  private project:string;
  private data:any[] = [];
  private columns:string[] = ['№ п/п', 'Рег. проект', 'Инициатор', 'Риск/Проблема', 'Адресат', 'Статус', 'Дата решения'];
  private pages:number = 0;

  public initialize():void {
    this.project = this.$state.params['project'];
    this.halResourceService
      .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString())
      .toPromise()
      .then((resources:QueryResource) => {
        let total:number = resources.results.total; //всего ex 29
        let pageSize:number = resources.results.pageSize; //в этой выборке ex 20
        let remainder = total % pageSize;
        this.pages = (total - remainder) / pageSize;
        if (remainder !== 0) {
          this.pages++;
        }
        resources.results.elements.map((el:HalResource) => {
          this.data.push(el);
        });
      });
  }
  public getColumns():string[] {
    return this.columns;
  }
  public getPages():number {
    return this.pages;
  }

  public getData():any[] {
    return this.data;
  }

  public getDataFromPage(i:number):any[] {
    this.data = [];
    this.halResourceService
      .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString(), {"offset": i})
      .toPromise()
      .then((resources:QueryResource) => {
        let total:number = resources.results.total; //всего ex 29
        let remainder = total % 20;
        this.pages = (total - remainder) / 20;
        if (remainder !== 0) {
          this.pages++;
        }
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
