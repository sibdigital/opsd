import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {Contract} from "core-components/contracts/contracts.component";

@Component({
  selector: 'op-contact-form',
  templateUrl: './contract-form.component.html',
  styleUrls: ['./contract-form.component.sass']
})
export class ContractFormComponent implements OnInit {
  @Input() contractId:string;
  @Input() projectId:string;
  formTitle:string = 'Новый государственный контракт';
  contract:Contract = {};

  public $element:JQuery;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    protected elementRef:ElementRef) {
  }

  ngOnInit():void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.contractId = this.$element.attr('contractId')!;
    this.projectId = this.$element.attr('projectId')!;
    if (this.contractId) {
      this.setContact();
    }
  }

  setContact() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/contracts/' + this.contractId).toPromise()
      .then((contract:Contract) => {
        this.contract = contract;
        this.contract.projectId = (this.projectId) ? Number(this.projectId) : null;
        this.formTitle = 'Правка контракта №' + contract.contractNum;
        this.convertContractsDates();
      })
      .catch((reason) => console.error(reason));
  }

  saveContract() {
    console.log(this.contract);
    this.httpClient.post(this.pathHelper.javaUrlPath + '/contracts/save', this.contract)
      .toPromise()
      .then((contract) => {
        this.contract = contract;
        // this.notificationService.addSuccess('Изменения сохранены');
      })
      .catch((reason) => {
        // this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
        console.error(reason);
      });
  }
  convertContractsDates() {
    this.contract.contractDate = this.convertFromDateStringToNewFormat(this.contract.contractDate);
    this.contract.dateBegin = this.convertFromDateStringToNewFormat(this.contract.dateBegin);
    this.contract.dateEnd = this.convertFromDateStringToNewFormat(this.contract.dateEnd);
    this.contract.auctionDate = this.convertFromDateStringToNewFormat(this.contract.auctionDate);
    this.contract.scheduleDate = this.convertFromDateStringToNewFormat(this.contract.scheduleDate);
    this.contract.scheduleDatePlan = this.convertFromDateStringToNewFormat(this.contract.scheduleDatePlan);
    this.contract.notificationDatePlan = this.convertFromDateStringToNewFormat(this.contract.notificationDatePlan);
    this.contract.notificationDate = this.convertFromDateStringToNewFormat(this.contract.notificationDate);
    this.contract.auctionDatePlan = this.convertFromDateStringToNewFormat(this.contract.auctionDatePlan);
    this.contract.contractDatePlan = this.convertFromDateStringToNewFormat(this.contract.contractDatePlan);
    this.contract.dateEndPlan = this.convertFromDateStringToNewFormat(this.contract.dateEndPlan);
    this.contract.conclusionOfEstimatedCostDate = this.convertFromDateStringToNewFormat(this.contract.conclusionOfEstimatedCostDate);
    this.contract.conclusionOfProjectDocumentationDate = this.convertFromDateStringToNewFormat(this.contract.conclusionOfProjectDocumentationDate);
    this.contract.conclusionOfEcologicalExpertiseDate = this.convertFromDateStringToNewFormat(this.contract.conclusionOfEcologicalExpertiseDate);
  }
  convertFromStringToDate(responseDate:string) {
    let dateComponents = responseDate.split('T');
    let datePieces = dateComponents[0].split("-");
    let timePieces = dateComponents[1].split(":");
    return new Date(Number(datePieces[2]), Number(datePieces[1]) - 1, Number(datePieces[0]),
      Number(timePieces[0]), Number(timePieces[1]), Number(timePieces[2]));
  }
  convertFromDateStringToNewFormat(responseDate:string) {
    try {
      let dateComponents = responseDate.split('T');
      let datePieces = dateComponents[0].split("-");
      let month = ("0" + (Number(datePieces[1]) - 1)).slice(-2);
      return datePieces[0] + '-' + month + '-' + datePieces[2];
    } catch (e) {
      return "";
    }
  }

}
DynamicBootstrapper.register({selector: 'op-contract-form', cls: ContractFormComponent});
