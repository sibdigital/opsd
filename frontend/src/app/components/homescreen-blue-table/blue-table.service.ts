import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";

export abstract class BlueTableService {
  protected readonly appBasePath:string;

  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }
  public getData(param?:any):any[] {
    return [];
  }
  public getColumns():string[] {
    return [];
  }
  public getTdData(row:any, i:number):string {
    return '';
  }

  public getTdClass(row:any, i:number):string {
    return '';
  }

  public getBasePath():string {
    return this.appBasePath;
  }
}
