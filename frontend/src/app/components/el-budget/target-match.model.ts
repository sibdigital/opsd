import {Target} from "core-components/targets/target.model";
import {Project} from "core-components/projects/project.model";
import {PurposeCriteria} from "core-components/el-budget/execution/purpose-criteria/purpose-criteria.model";

export class TargetMatch {
  purposeCriteria:PurposeCriteria | null = null;
  target:Target | null = null;
  project:Project | undefined = undefined;
  attachedTarget:boolean = false;
  disableTargetChoice:boolean = false;

}
