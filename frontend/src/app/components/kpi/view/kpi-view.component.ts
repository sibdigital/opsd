import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpHeaders, HttpParams} from "@angular/common/http";
import {DomSanitizer} from "@angular/platform-browser";

@Component({
  selector: 'op-kpi-view',
  templateUrl: './kpi-view.component.html',
  styleUrls: ['./kpi-view.component.sass']
})
export class KpiViewComponent implements OnInit {
  report:any;
  @Input() userId:string;
  @Input() projectId:string;
  public $element:JQuery;
  constructor(protected pathHelper:PathHelperService,
              protected httpClient:HttpClient,
              protected elementRef:ElementRef,
              private sanitizer:DomSanitizer) {
  }

  ngOnInit():void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.userId = this.$element.attr('userId')!;
    this.projectId = this.$element.attr('projectId')!;
    this.getReport();
  }

  private getReport() {
    const headers = new HttpHeaders({
      'Accept': 'text/html, application/xhtml+xml, */*',
      'Content-Type': 'text/html'
    });
    const params = new HttpParams()
      .set('userId', this.userId || '')
      .set('projectId', this.projectId || '');
    this.httpClient.get(
      this.pathHelper.javaUrlPath + `/kpi/report`,
      {headers: headers, responseType: 'text', params: params})
      .toPromise()
      .then((response:any) => {
        this.report = this.sanitizer.bypassSecurityTrustHtml(response);
      })
      .catch((reason) => console.error(reason));
  }
}
DynamicBootstrapper.register({selector: 'op-kpi-view', cls: KpiViewComponent});
