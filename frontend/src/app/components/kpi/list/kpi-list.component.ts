import {Component, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {KPI} from "core-components/kpi/schema";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {MatTableDataSource} from "@angular/material/table";
import {Page, Paginator} from "core-components/pages/pages.component";
import {PageEvent} from "@angular/material/paginator";

@Component({
  selector: 'op-kpi-list',
  templateUrl: './kpi-list.component.html',
  styleUrls: ['./kpi-list.component.sass']
})
export class KpiListComponent implements OnInit {
  public kpis:KPI[];
  dataSource = new MatTableDataSource<KPI>();
  displayedColumns:string[] = ['name', 'query'];
  paginatorSettings = new Paginator();

  constructor(protected pathHelper:PathHelperService,
              protected httpClient:HttpClient) {
  }

  ngOnInit():void {
    this.loadKpis();
  }

  private loadKpis(size?:number, index?:number) {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + `/kpis`,{
        params: new HttpParams()
          .set('size', size ? size.toString() : '20')
          .set('page', index ? index.toString() : '0')
      }).toPromise()
      .then((response:any) => {
        this.kpis = response._embedded.kpis;
        this.paginatorSettings = response.page;
        this.dataSource.data = this.kpis;
      })
      .catch((reason) => console.error(reason));
  }

  public pageChanged(event:PageEvent) {
    this.loadKpis(event.pageSize, event.pageIndex);
  }
}
DynamicBootstrapper.register({selector: 'op-kpi-list', cls: KpiListComponent});
