import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {HttpClient, HttpParams} from "@angular/common/http";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {KPI} from "core-components/kpi/schema";

@Component({
  selector: 'op-kpi-form',
  templateUrl: './kpi-form.component.html',
  styleUrls: ['./kpi-form.component.sass']
})
export class KPIFormComponent implements OnInit {
  public kpi = new KPI();
  public $element:JQuery;
  @Input() id:string;
  constructor(
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    protected elementRef:ElementRef,
  ) {
  }

  ngOnInit():void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.id = this.$element.attr('id')!;
    this.loadKPI();
  }

  sendRequest(value:string) {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/kpi/execute').toPromise()
      .then((response) => {
        console.log(response);
      })
      .catch((reason) => console.error(reason));
  }

  saveKPI() {
    this.httpClient.post(
      this.pathHelper.javaApiPath.javaApiBasePath + '/kpis', this.kpi).toPromise()
      .then((response:KPI) => {
        this.kpi = response;
      })
      .catch((reason) => console.error(reason));
  }


  private loadKPI() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + `/kpis/${this.id}`).toPromise()
      .then((response:KPI) => {
        this.kpi = response;
      })
      .catch((reason) => console.error(reason));
  }
}

DynamicBootstrapper.register({selector: 'op-kpi-form', cls: KPIFormComponent});
