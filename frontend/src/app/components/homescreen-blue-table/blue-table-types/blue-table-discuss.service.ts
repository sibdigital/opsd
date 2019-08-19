import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export class BlueTableDiscussService extends BlueTableService {
  private project:string;
  private data:any[] = [];
  private columns:string[] = ['Проект', 'Куратор/\nРП', 'Тема', 'Дата последнего сообщения'];
  private pages:number = 0;

  public initialize():void {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.topics.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        let total:number = resources.total; //всего ex 29
        let pageSize:number = resources.pageSize; //в этой выборке ex 20
        let remainder = total % pageSize;
        this.pages = (total - remainder) / pageSize;
        if (remainder !== 0) {
          this.pages++;
        }
        resources.elements.map((el:HalResource) => {
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
    if ( i === 0) {
      i = 1;
    } else if (i > this.getPages()) {
      i = this.getPages();
    }
    this.data = [];
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.topics.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
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
        return '<a href="' + super.getBasePath() + '/projects/' + row.project.identifier + '">' + row.project.name + '</a>';
        break;
      }
      case 1: {
        let result:string = '';
        if (row.project.curator) {
          result += '<a href="' + super.getBasePath() + '/users/' + row.project.curator.id + '">' + row.project.curator.fio + '</a>';
        }
        result += '<br>';
        if (row.project.rukovoditel) {
          result += '<a href="' + super.getBasePath() + '/users/' + row.project.rukovoditel.id + '">' + row.project.rukovoditel.fio + '</a>';
        }
        return result;
        break;
      }
      case 2: {
        return row.subject;
        break;
      }
      case 3: {
        return this.format(row.updatedOn);
        break;
      }
    }
    return '';
  }

  public getTdClass(row:any, i:number):string {
    return '';
  }

  public getDataWithLimit(i:number):any[] {
    let filters = new ApiV3FilterBuilder();
    filters.add('dueDate', '<t+', [i.toString()]);
    this.data = [];
    this.halResourceService
      .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString(), {"filters": filters.toJson()})
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

  public getDataWithFilter(param:string):any[] {
    let filters;
    switch (param) {
      case 'vrabote': {
        filters = new ApiV3FilterBuilder();
        filters.add('status', '=', ["2"]);
        break;
      }
      case 'predstoyashie': {
        filters = new ApiV3FilterBuilder();
        filters.add('dueDate', '>t+', ["0"]);
        break;
      }
    }
    this.data = [];
    this.halResourceService
      .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString(), filters ? {"filters": filters.toJson()} :null)
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

  public format(input:string):string {
    return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
  }
}
