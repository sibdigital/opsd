import {HalResource} from 'core-app/modules/hal/resources/hal-resource';

export interface WpTargetResourceLinks {
  delete():Promise<any>;

  updateImmediately(payload:any):Promise<any>;
}

export class WpTargetResource extends HalResource {

  // properties
  public id: number;
  public project_id: number;
  public work_package_id: number;
  public wp_target_id: number;
  public year: number;
  public quarter: number;
  public month: number;
  public plan_value: number;
  public value: number;
  public name: string;

  // Links
  public $links:WpTargetResourceLinks;

  public updateType(type:any) {
    return this.$links.updateImmediately({type: type});
  }
}

export interface WpTargetResource extends WpTargetResourceLinks {
}

