import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {Contract} from "core-components/contracts/contracts.component";
import {FormGroup, FormControl, FormBuilder} from "@angular/forms";

@Component({
  selector: 'op-contact-form',
  templateUrl: './contract-form.component.html',
  styleUrls: ['./contract-form.component.sass']
})
export class ContractFormComponent implements OnInit {
  // contractForm:FormGroup;
  @Input() contractId:string;
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
    if (this.contractId) {
      this.setContact();
    }
  }

  setContact() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/contracts/' + this.contractId).toPromise()
      .then((contract:Contract) => {
        this.contract = contract;
        this.formTitle = 'Правка контракта №' + contract.contractNum;
        this.convertContractsDates();
      })
      .catch((reason) => console.error(reason));
  }

  saveContract() {
    console.log(this.contract);
    this.httpClient.post(
      this.pathHelper.javaUrlPath + '/contracts/save', this.contract);
  }
  convertContractsDates() {
    this.contract.contractDate = this.convertFromDateStringToNewFormat(this.contract.contractDate);
    this.contract.dateBegin = this.convertFromDateStringToNewFormat(this.contract.dateBegin);
    this.contract.dateEnd = this.convertFromDateStringToNewFormat(this.contract.dateEnd);
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
      return datePieces[0] + '-' + (Number(datePieces[1]) - 1) + '-' + datePieces[2];
    } catch (e) {
      return "";
    }
  }

}
DynamicBootstrapper.register({selector: 'op-contract-form', cls: ContractFormComponent});
