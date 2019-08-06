import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";

export class BlueTableKtService extends BlueTableService {
  private project:string;
  private filters:ApiV3FilterBuilder | null = null;
  private data:any[] = [];
  private columns:string[] = ['№ п/п', 'Мероприятие', 'Отв. Исполнитель', 'Срок выполнения', 'Статус', 'Факт. выполнение', 'Проблемы'];
  private pages:number = 0;

  public initialize():void {
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
    if ( i === 0) {
      i = 1;
    } else if (i > this.getPages()) {
      i = this.getPages();
    }
    this.data = [];
    let promise:Promise<QueryResource>;
    if (this.project === '0') {
      promise = this.halResourceService
        .get<QueryResource>(this.pathHelper.api.v3.queries.default.toString(), this.filters ? {"filters": this.filters.toJson(), "offset": i} :{"offset": i})
        .toPromise();
    } else {
      promise = this.halResourceService
        .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString(), this.filters ? {"filters": this.filters.toJson(), "offset": i} :{"offset": i})
        .toPromise();
    }
    promise.then((resources:QueryResource) => {
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
        return this.format(row.dueDate);
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

  public getDataWithLimit(i:number):any[] {
    this.filters = new ApiV3FilterBuilder();
    this.filters.add('dueDate', '<t+', [i.toString()]);
    this.data = [];
    let promise:Promise<QueryResource>;
    if (this.project === '0') {
      promise = this.halResourceService
        .get<QueryResource>(this.pathHelper.api.v3.queries.default.toString(), this.filters ? {"filters": this.filters.toJson()} :null)
        .toPromise();
    } else {
      promise = this.halResourceService
        .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString(), this.filters ? {"filters": this.filters.toJson()} :null)
        .toPromise();
    }
    promise.then((resources:QueryResource) => {
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

  public getDataWithFilter(param:string):any[] {
    if (param.startsWith('project')) {
      this.project = param.slice(7);
      this.filters = null;
    }
    this.data = [];
    this.filters;
    switch (param) {
      case 'all': {
        this.filters = new ApiV3FilterBuilder();
        this.filters.add('status', '=', ["2"]);
        break;
      }
      case 'vrabote': {
        this.filters = new ApiV3FilterBuilder();
        this.filters.add('status', '=', ["2"]);
        break;
      }
      case 'predstoyashie': {
        this.filters = new ApiV3FilterBuilder();
        this.filters.add('dueDate', '>t+', ["0"]);
        break;
      }
    }
    let promise:Promise<QueryResource>;
    if (this.project === '0') {
      promise = this.halResourceService
        .get<QueryResource>(this.pathHelper.api.v3.queries.default.toString(), this.filters ? {"filters": this.filters.toJson()} :null)
        .toPromise();
    } else {
      promise = this.halResourceService
        .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString(), this.filters ? {"filters": this.filters.toJson()} :null)
        .toPromise();
    }
    promise.then((resources:QueryResource) => {
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

  public format(input:string):string {
    if (input) {
      return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
    } else {
      return input;
    }
  }
}
