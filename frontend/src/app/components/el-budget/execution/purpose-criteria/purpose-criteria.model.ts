import {PurposeCriteriaMonthlyExecutions} from "core-components/el-budget/execution/purpose-criteria/purpose-criteria-monthly-executions.model";

export class PurposeCriteria {
  purposeCriteriaMetaId:number | null = null;
  description:string = "";
  executionConfirmingDocuments:any;
  risks:any;
  purposeCriteriaMonthlyExecutions:PurposeCriteriaMonthlyExecutions | null = null;

}
