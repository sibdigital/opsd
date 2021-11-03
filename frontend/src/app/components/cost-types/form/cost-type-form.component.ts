import {Component, ElementRef, Input, OnInit, ViewChild} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {DateAdapter, MAT_DATE_LOCALE} from "@angular/material/core";
import {MatFormFieldControl} from "@angular/material/form-field";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {FormArray, FormBuilder, FormControl, FormGroup, Validators} from "@angular/forms";
import {CostType} from "core-components/cost-types/cost-type.model";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {MatTable, MatTableDataSource} from "@angular/material/table";
import {DatePipe} from "@angular/common";
import {Object} from "es6-shim";
import {EbCostType} from "core-components/eb-cost-types/eb-cost-types.model";
import {MatDialog, MatDialogConfig} from "@angular/material/dialog";
import {EbCostTypesModalSelectorDialogComponent} from "core-components/eb-cost-types/eb-cost-types-modal-selector-dialog/eb-cost-types-modal-selector-dialog.component";
import {RegEbCostType} from "core-components/eb-cost-types/reg-eb-cost-types.model";
import {EbCostTypesModalHelpComponent} from "core-components/eb-cost-types/eb-cost-types-modal-help/eb-cost-types-modal-help.component";
// import * as cloneDeep from "lodash/cloneDeep";

export class Rate {
  id?:number|null;
  validFrom?:Date;
  rate?:number;
  type:string;
  projectId?:number|null;
  userId?:number|null;
  costType?:CostType|null;
  deleted:boolean;
}

@Component({
  selector: 'op-cost-type-form',
  templateUrl: './cost-type-form.component.html',
  styleUrls: ['./cost-type-form.component.sass'],
  providers:[
    {provide: MAT_DATE_LOCALE, useValue: 'ru-RU'},
    {provide: MatFormFieldControl, useExisting:CostTypeFormComponent}
  ],
  entryComponents:[EbCostTypesModalSelectorDialogComponent]
})
export class CostTypeFormComponent implements OnInit {
  @Input() costTypeId:string;
  @ViewChild('rateTable') rateTable:MatTable<Rate>;
  @ViewChild('ebCostTable') ebCostTable:MatTable<EbCostType>;
  cost_type_form:FormGroup;
  add_rate_form:FormGroup;
  add_eb_cost_form:FormGroup;
  formTitle:string = 'Новый тип затрат';
  costType:CostType = {};
  displayedRateColumns:string[] = ['index', 'validFrom', 'rate', 'delete'];
  displayedEbCostColumns:string[] = ['code', 'name', 'delete'];
  rateDataSource:Rate[] = [];
  ebDataSource:EbCostType[] = [];
  addRateFormDisable:boolean = true;
  addEbCostFormDisable:boolean = true;
  selectedEbCostType:EbCostType | undefined;

  public $element:JQuery;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    protected elementRef:ElementRef,
    public dialog:MatDialog,
    private notificationService:NotificationsService,
    private adapter:DateAdapter<any>,
    private datepipe:DatePipe,
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
    this.add_rate_form = this.fb.group({
      'validFrom':new FormControl('', Validators.required),
      'rate':new FormControl('', Validators.required),
    });
    // this.add_eb_cost_form = this.fb.group({
    //   ''
    // });
    if (this.costTypeId) {
      this.setCostType();
      this.setRateHistory();
      this.setEbCosts();
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
        this.formTitle = 'Тип затрат: ' + costType.name;
      })
      .catch((reason) => console.error(reason));
  }
  setRateHistory() {
    this.httpClient.get(this.pathHelper.javaUrlPath + '/api/rates/search/findByCostType_Id',
      {
        params: new HttpParams()
          .set('costTypeId', this.costTypeId)})
      .toPromise()
      .then((rates:HalResource) => {
        rates._embedded.rates.forEach(
          (rate:any) => {
            if (rate.validFrom) {
              rate.validFrom = this.convertFromStringToDate(rate.validFrom);
            }
          });
        this.rateDataSource = rates._embedded.rates;
      });
  }
  setEbCosts() {
    this.httpClient.get(this.pathHelper.javaUrlPath + '/ebCostTypesByCostTypeId',
      {
        params: new HttpParams()
          .set('costTypeId', this.costTypeId)})
      .toPromise()
      .then((ebCosts:EbCostType[]) => {
        this.ebDataSource = ebCosts;
      });
  }
  showAddRateForm() {
    this.addRateFormDisable = false;
  }
  closeAddRateForm() {
    this.addRateFormDisable = true;
    this.resetAddRateForm();
  }
  resetAddRateForm() {
    this.add_rate_form.reset();
    this.add_rate_form.markAsUntouched();
  }
  addNewRate() {
    this.markFormTouched(this.add_rate_form);
    if (this.add_rate_form.valid) {
      var newRate:Rate = new Rate();
      newRate.id = null;
      newRate.validFrom = this.add_rate_form.controls['validFrom'].value;
      newRate.rate = parseInt(this.add_rate_form.controls['rate'].value);
      newRate.deleted = false;
      this.rateDataSource.push(newRate);
      this.rateTable.renderRows();
      this.addRateFormDisable = true;
      this.resetAddRateForm();
    }
  }
  deleteRate(rate:Rate):void {
    rate.deleted = true;
  }
  closeEbCostForm():void {
    this.addEbCostFormDisable = true;
    this.resetEbCostForm();
  }
  resetEbCostForm() {
    this.selectedEbCostType = undefined;
  }
  showNewEbCostForm():void {
    this.addEbCostFormDisable = false;
  }
  chooseEbCostType() {
    let matDialogConfig:MatDialogConfig = {
      panelClass: "dialog-responsive",
      autoFocus: false,
      data: {
        excludedEbCosts: this.ebDataSource
      }
    };

    const dialogRef = this.dialog.open(EbCostTypesModalSelectorDialogComponent, matDialogConfig);

    dialogRef.afterClosed().subscribe(result => {
      if (result.data) {
        this.selectedEbCostType = result.data.ebCostType;
        // this.outputselectedTarget.emit(result.data)
      }
    });
  }
  addNewEbCostType() {
    if (this.selectedEbCostType) {
      this.ebDataSource.push(this.selectedEbCostType);
      this.ebCostTable.renderRows();
      this.addEbCostFormDisable = true;
      this.resetEbCostForm();
    }
  }
  deleteEbCostType(ebCostType:EbCostType) {
    this.ebDataSource = this.ebDataSource.filter(ect => ect.id !== ebCostType.id);
    this.ebCostTable.renderRows();
  }
  saveCostType() {
    this.markFormTouched(this.cost_type_form);
    if (this.cost_type_form.valid) {
      this.rateDataSource.forEach(
        (rate) => {
          rate.costType = (this.costTypeId) ? {id: parseInt(this.costTypeId)} : null;
          rate.type = 'CostType';
        }
      );
      var costTypeDto = {
        costType: this.costType,
        rateList: this.rateDataSource,
        ebCostTypeList: this.ebDataSource,
      };
      this.httpClient.post(this.pathHelper.javaUrlPath + '/costType/save', costTypeDto)
        .toPromise()
        .then((costType) => {
          // this.costType = costType;
          this.notificationService.addSuccess('Изменения сохранены');
        })
        .catch((reason) => {
          this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
          console.error(reason);
        });
    }
  }
  showHelpForm() {
    let matDialogConfig:MatDialogConfig = {
      panelClass: "dialog-responsive",
      autoFocus: false,
    };

    const dialogRef = this.dialog.open(EbCostTypesModalHelpComponent, matDialogConfig);
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
  convertFromStringToDate(responseDate:string) {
    let dateComponents = responseDate.split('T');
    let datePieces = dateComponents[0].split("-");
    let timePieces = dateComponents[1].split(":");
    return new Date(Number(datePieces[0]), Number(datePieces[1]) - 1, Number(datePieces[2]),
      Number(timePieces[0]), Number(timePieces[1]), Number(timePieces[2]));
  }
}
DynamicBootstrapper.register({selector: 'op-cost-type-form', cls: CostTypeFormComponent});
