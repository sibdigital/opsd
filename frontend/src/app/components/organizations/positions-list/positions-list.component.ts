import {Component, OnInit} from "@angular/core";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {Position} from "core-components/organizations/schema";
import {MatTableDataSource} from "@angular/material/table";
import {Paginator} from "core-components/pages/pages.component";
import {PageEvent} from "@angular/material/paginator";

@Component({
  selector: 'op-positions-list',
  templateUrl: './positions-list.component.html',
  styleUrls: ['./positions-list.component.sass']
})
export class PositionsListComponent implements OnInit {
  public positions:Position[];
  dataSource = new MatTableDataSource<Position>();
  displayedColumns:string[] = ['name', 'delete'];
  paginatorSettings = new Paginator();

  constructor(protected pathHelper:PathHelperService,
              protected httpClient:HttpClient) {
  }

  ngOnInit(): void {
    this.loadPositions();
  }

  private loadPositions(size?:number, index?:number) {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + `/positions/search/findAllByIdIsNotNullOrderByNameAsc`,{
        params: new HttpParams()
          .set('size', size ? size.toString() : '25')
          .set('page', index ? index.toString() : '0')
      }).toPromise()
      .then((response:any) => {
        this.positions = response._embedded.positions;
        this.paginatorSettings = response.page;
        this.dataSource.data = this.positions;
      })
      .catch((reason) => console.error(reason));
  }

  public pageChanged(event:PageEvent) {
    this.loadPositions(event.pageSize, event.pageIndex);
  }
}
DynamicBootstrapper.register({selector: 'op-positions-list', cls: PositionsListComponent});
