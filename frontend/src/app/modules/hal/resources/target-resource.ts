import {HalResource} from 'core-app/modules/hal/resources/hal-resource';
import {RelationResourceLinks} from "core-app/modules/hal/resources/relation-resource";

export interface TargetResourceLinks {
  delete():Promise<any>;

  updateImmediately(payload:any):Promise<any>;
}

export class TargetResource extends HalResource {

  // properties
  public project_id: number;
  public work_package_id: number;
  public wp_target_id: number;
  public year: number;
  public quarter: number;
  public month: number;
  public plan_value: number;
  public value: number;

  // Links
  public $links:TargetResourceLinks;

  public updateType(type:any) {
    return this.$links.updateImmediately({type: type});
  }
}

export interface TargetResource extends TargetResourceLinks {
}

