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
import {CostType} from "core-components/cost-types/cost-type.model";

@Component({
  selector: 'op-cost-type-form',
  templateUrl: './cost-type-form.component.html',
  styleUrls: ['./cost-type-form.component.sass'],
  providers:[
    {provide: MAT_DATE_LOCALE, useValue: 'ru-RU'},
    {provide: MatFormFieldControl, useExisting:CostTypeFormComponent}
  ]
})
export class CostTypeFormComponent implements OnInit {
  @Input() costTypeId:string;
  cost_type_form:FormGroup;
  formTitle:string = 'Новый тип затрат';
  costType:CostType = {};

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
    this.costTypeId = this.$element.attr('costTypeId')!;
    this.cost_type_form = this.fb.group({
      'name':new FormControl('', Validators.required),
      'unit':new FormControl('', Validators.required),
      'unitPlural':new FormControl('', Validators.required),
      'default':new FormControl(''),
    });
    if (this.costTypeId) {
      this.setCostType();
    } else {
      // this.contract = new Contract();
      // this.contract.projectId = (this.projectId) ? Number(this.projectId) : null;
    }
  }

  setCostType() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/costTypes/' + this.costTypeId).toPromise()
      .then((costType:CostType) => {
        this.costType = costType;
        this.formTitle = 'Тип затрат:' + costType.name;
      })
      .catch((reason) => console.error(reason));
  }
  saveCostType() {
    this.markFormTouched(this.cost_type_form);
    if (this.cost_type_form.valid) {
      this.httpClient.post(this.pathHelper.javaUrlPath + '/contracts/save', this.costType )
        .toPromise()
        .then((costType) => {
          this.costType = costType;
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


}
DynamicBootstrapper.register({selector: 'op-cost-type-form', cls: CostTypeFormComponent});
