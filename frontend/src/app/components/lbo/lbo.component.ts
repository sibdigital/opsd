import {Component, ElementRef, Input, OnInit, ViewChild} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {FormBuilder, FormControl, FormGroup, Validators} from "@angular/forms";
import {MatTable} from "@angular/material/table";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {DateAdapter} from "@angular/material/core";

export class Lbo {
  id:number|null;
  project:any;
  year:number;
  sum:number;
}

@Component({
  selector: 'op-lbo',
  templateUrl: './lbo.component.html',
  styleUrls: ['./lbo.component.sass'],
})
export class LboComponent implements OnInit {
  displayedColumns:string[] = ['index', 'year', 'sum', 'delete'];
  dataSource:Lbo[] = [];
  formTitle:string = 'Лимиты бюджетных обязательств';
  add_lbo_form:FormGroup;
  addFormDisable = true;
  @Input() projectId:string;
  @ViewChild(MatTable) table:MatTable<Lbo>;
  public $element:JQuery;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    protected elementRef:ElementRef,
    private notificationService:NotificationsService,
    private adapter:DateAdapter<any>,
    private fb:FormBuilder
  ) {
  }
  ngOnInit():void {
    this.adapter.setLocale('ru');
    this.$element = jQuery(this.elementRef.nativeElement);
    this.projectId = this.$element.attr('projectId')!;
    this.add_lbo_form = this.fb.group({
      'year':new FormControl('', [Validators.required, Validators.pattern('^(20)\\d{2}$')]),
      'sum':new FormControl('', [Validators.required, Validators.pattern('^(\\d*\\.)?\\d+$')])
    });
    this.httpClient.get(this.pathHelper.javaUrlPath + '/api/lboes/search/findByProject_Id',
        {
          params: new HttpParams()
            .set('projectId', this.projectId)})
      .toPromise()
      .then((lboes:HalResource) => {
        this.dataSource = lboes._embedded.lboes;
      });
  }
  showAddForm():void {
   this.addFormDisable = false;
  }
  closeAddForm():void {
    this.addFormDisable = true;
    this.resetAddForm();
  }
  resetAddForm():void {
    this.add_lbo_form.reset();
    this.add_lbo_form.markAsUntouched();
  }
  addNewLbo():void {
    this.markFormTouched(this.add_lbo_form);
    if (this.add_lbo_form.valid) {
      var newLbo:Lbo = new Lbo();
      var projectId = parseInt(this.projectId) || null;
      newLbo.id = null;
      newLbo.project = projectId ? {id: projectId} : null;
      newLbo.year = parseInt(this.add_lbo_form.controls['year'].value);
      newLbo.sum = parseInt(this.add_lbo_form.controls['sum'].value);
      this.httpClient.post(this.pathHelper.javaUrlPath + '/lbo/save', newLbo)
        .toPromise()
        .then((savedLbo:Lbo) => {
          this.dataSource.push(savedLbo);
          this.table.renderRows();
          this.notificationService.addSuccess('Изменения сохранены');
          this.addFormDisable = true;
          this.resetAddForm();
        })
        .catch((reason) => {
          this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
          console.error(reason);
        });

    }
  }
  deleteLbo(id:number):void {
    this.httpClient.post(this.pathHelper.javaUrlPath + '/lbo/delete', {},
      { params: new HttpParams().set('lboId', id.toString())})
      .toPromise()
      .then((object) => {
        for (let i = 0; i < this.dataSource.length; ++i) {
          if (this.dataSource[i].id === id) {
            this.dataSource.splice(i, 1);
            this.table.renderRows();
          }
        }
        this.notificationService.addSuccess('Изменения сохранены');
      })
      .catch((reason) => {
        this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
        console.error(reason);
      });
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
DynamicBootstrapper.register({selector: 'op-lbo', cls: LboComponent});
