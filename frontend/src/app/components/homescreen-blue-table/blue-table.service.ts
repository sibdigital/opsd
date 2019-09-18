import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {StateService} from "@uirouter/core";

export abstract class BlueTableService {
  protected readonly appBasePath:string;

  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    readonly $state:StateService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
    this.initialize();
  }
  // tslint:disable-next-line:no-empty
  public initialize() {
  }

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {resolve([]); });
  }
  public getDataWithFilter(param:string):Promise<any[]>  {
    return new Promise((resolve) => {resolve([]); });
  }
  public getColumns():string[] {
    return [];
  }
  public getPages():number {
    return 0;
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

  public pagesToText(i:number):string {
    return String(i + 1);
  }
}
