import {Component, OnInit} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";

export interface Contract {
  id?:number;
  projectId?:number|null;
  contractSubject?:string;
  contractDate?:any;
  price?:number;
  executor?:string;
  createdAt?:string;
  updatedAt?:string;
  contractNum?:string;
  isApprove?:boolean;
  eisHref?:string;
  name?:string;
  sposob?:string;
  gosZakaz?:string;
  dateBegin?:any;
  dateEnd?:any;
  etaps?:string;
  auctionDate?:any;
  scheduleDate?:any;
  nmck?:number;
  scheduleDatePlan?:any;
  notificationDatePlan?:any;
  notificationDate?:any;
  auctionDatePlan?:any;
  contractDatePlan?:any;
  dateEndPlan?:any;
  note?:string;
  conclusionOfEstimatedCostDetails?:string;
  conclusionOfEstimatedCostNumber?:string;
  conclusionOfEstimatedCostDate?:any;
  conclusionOfProjectDocumentationDetails?:string;
  conclusionOfProjectDocumentationNumber?:string;
  conclusionOfProjectDocumentationDate?:any;
  conclusionOfEcologicalExpertiseDetails?:string;
  conclusionOfEcologicalExpertiseNumber?:string;
  conclusionOfEcologicalExpertiseDate?:any;
}

@Component({
  selector: 'op-contracts',
  templateUrl: './contracts.component.html',
  styleUrls: ['./contracts.component.sass'],
})
export class ContractsComponent implements OnInit {
  contracts:Contract[];
  public columns:[];
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
  ) {}

  ngOnInit():void {
    // this.getPages();
    // this.getProjects();
    // this.getGroups();
  }
}
DynamicBootstrapper.register({ selector: 'op-contracts', cls: ContractsComponent });
