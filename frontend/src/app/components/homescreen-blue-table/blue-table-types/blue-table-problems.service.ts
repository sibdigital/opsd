import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";

export class BlueTableProblemsService extends BlueTableService {
  private project:string;
  private data:any[] = [];
  private columns:string[] = ['№ п/п', 'Рег. проект', 'Инициатор', 'Риск/Проблема', 'Адресат', 'Статус', 'Дата решения'];
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
    //TODO:dodelat
    return this.data;
  }

  public getTdData(row:any, i:number):string {
    switch (i) {
      case 0: {
        return row.id;
        break;
      }
      case 1: {
        return row.project ? row.project.$links.self.title :'';
        break;
      }
      case 2: {
        return row.userCreator ? row.userCreator.$links.self.title :'';
        break;
      }
      case 3: {
        return row.risk;
        break;
      }
      case 5: {
        return row.status;
        break;
      }
      case 6: {
        return row.solution_date;
        break;
      }
    }
    return '';
  }

  public getTdClass(row:any, i:number):string {
    return '';
  }

  public getDataWithFilter(param:string):any[] {
    if (param.startsWith('project')) {
      this.project = param.slice(7);
    }
    this.data = [];
    let promise:Promise<CollectionResource<HalResource>>;
    let filter;
    switch (param) {
      case 'solved': {
        filter = 'solved';
        break;
      }
      case 'notsolved': {
        filter = 'created';
        break;
      }
    }
    if (this.project === '0') {
      promise = this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(),
          filter ? {"status": filter} : null)
        .toPromise();
    } else {
      promise = this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(),
          filter ? {"status": filter, project: this.project} : {project: this.project})
        .toPromise();
    }
    promise.then((resources:CollectionResource<HalResource>) => {
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
    return this.data;
  }
}
