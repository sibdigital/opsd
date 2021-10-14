import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {Contract} from "core-components/contracts/contract.model";
import {DateAdapter, MAT_DATE_FORMATS, MAT_DATE_LOCALE} from "@angular/material/core";
import {MatFormFieldControl} from "@angular/material/form-field";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {FormArray, FormBuilder, FormControl, FormGroup, Validators} from "@angular/forms";

@Component({
  selector: 'op-contact-form',
  templateUrl: './contract-form.component.html',
  styleUrls: ['./contract-form.component.sass'],
  providers:[
    {provide: MAT_DATE_LOCALE, useValue: 'ru-RU'},
    {provide: MatFormFieldControl, useExisting:ContractFormComponent}
  ]
})
export class ContractFormComponent implements OnInit {
  @Input() contractId:string;
  @Input() projectId:string;
  contract_form:FormGroup;
  formTitle:string = 'Новый государственный контракт';
  contract:Contract = {};

  numberRegEx = /\-?\d*\.?\d{1,2}/;

  public $element:JQuery;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    protected elementRef:ElementRef,
    private notificationService:NotificationsService,
    private adapter:DateAdapter<any>,
    private fb:FormBuilder) {
  }

  ngOnInit():void {
    this.adapter.setLocale('ru');
    this.$element = jQuery(this.elementRef.nativeElement);
    this.contractId = this.$element.attr('contractId')!;
    this.projectId = this.$element.attr('projectId')!;
    this.contract_form = this.fb.group({
      'contractSubject':new FormControl('', Validators.required),
      'contractDate':new FormControl('', Validators.required),
      'price':new FormControl('', [Validators.required, Validators.pattern('^(\\d*\\.)?\\d+$')]),
      'executor':new FormControl('', Validators.required),
      'contractNum':new FormControl('', Validators.required),
      'eisHref':new FormControl(),
      'name':new FormControl(),
      'sposob':new FormControl(),
      'gosZakaz':new FormControl(),
      'dateBegin':new FormControl(),
      'dateEnd':new FormControl(),
      'etaps':new FormControl(),
      'auctionDate':new FormControl(),
      'scheduleDate':new FormControl(),
      'nmck':new FormControl('', Validators.pattern('^(\\d*\\.)?\\d+$')),
      'scheduleDatePlan':new FormControl(),
      'notificationDatePlan':new FormControl(),
      'notificationDate':new FormControl(),
      'auctionDatePlan':new FormControl(),
      'contractDatePlan':new FormControl(),
      'dateEndPlan':new FormControl(),
      'note':new FormControl(),
      'conclusionOfEstimatedCostDetails':new FormControl(),
      'conclusionOfEstimatedCostNumber':new FormControl(),
      'conclusionOfEstimatedCostDate':new FormControl(),
      'conclusionOfProjectDocumentationDetails':new FormControl(),
      'conclusionOfProjectDocumentationNumber':new FormControl(),
      'conclusionOfProjectDocumentationDate':new FormControl(),
      'conclusionOfEcologicalExpertiseDetails':new FormControl(),
      'conclusionOfEcologicalExpertiseNumber':new FormControl(),
      'conclusionOfEcologicalExpertiseDate':new FormControl(),
    });
    if (this.contractId) {
      this.setContact();
    } else {
      this.contract = new Contract();
      this.contract.projectId = (this.projectId) ? Number(this.projectId) : null;
    }
  }

  setContact() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/contracts/' + this.contractId).toPromise()
      .then((contract:Contract) => {
        this.contract = contract;
        this.contract.projectId = (this.projectId) ? Number(this.projectId) : null;
        this.formTitle = 'Контракт №' + contract.contractNum + ' ' + contract.contractSubject;
        this.convertContractsDates();
      })
      .catch((reason) => console.error(reason));
  }

  saveContract() {
    this.markFormTouched(this.contract_form);
    if (this.contract_form.valid) {
      this.httpClient.post(this.pathHelper.javaUrlPath + '/contracts/save', this.contract)
        .toPromise()
        .then((contract) => {
          this.contract = contract;
          this.notificationService.addSuccess('Изменения сохранены');
        })
        .catch((reason) => {
          this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
          console.error(reason);
        });
    }
  }
  markFormTouched(group:FormGroup) {
    Object.keys(group.controls).forEach((key:string) => {
      const control = group.controls[key];
      if (control instanceof FormGroup) {
        control.markAsTouched(); this.markFormTouched(control);
      }
      else {
        control.markAsTouched();
      }
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
