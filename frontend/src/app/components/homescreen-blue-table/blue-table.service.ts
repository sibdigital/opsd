import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {StateService} from "@uirouter/core";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ConfirmDialogModal} from "core-components/modals/confirm-dialog/confirm-dialog.modal";

export abstract class BlueTableService {
  protected readonly appBasePath:string;
  protected columns:string[] = [];
  protected pages:number = 0;
  protected configs:any;
  protected table_data:any;
  protected data:any;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    readonly $state:StateService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }
  public initializeAndGetData():Promise<any[]> {
    return Promise.resolve([]);
  }
  public getDataFromPage(i:number):Promise<any[]> {
    return Promise.resolve([]);
  }
  public getDataWithFilter(param:string):Promise<any[]>  {
    return Promise.resolve([]);
  }
  public getColumns():string[] {
    return this.columns;
  }
  public getPages():number {
    return this.pages;
  }
  public getTdData(row:any, i:number):string {
    return '';
  }
  public getTdClass(row:any, i:number):string {
    return '';
  }
  public getTrClass(row:any):string {
    return '';
  }
  public getBasePath():string {
    return this.appBasePath;
  }
  public getConfigs():any {
    return this.configs;
  }
  public getDatas():any {
    return this.table_data;
  }
  public pagesToText(i:number):string {
    return String(i + 1);
  }
}
