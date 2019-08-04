import {HalResource} from 'core-app/modules/hal/resources/hal-resource';

export class TargetResource extends HalResource {

  // properties
  public project_id: number;
  public status_id: number;
  public name: string;
  public type_id: number;
  public unit: string;
  public year: number;
  public quarter: number;
  public value: number;

}


