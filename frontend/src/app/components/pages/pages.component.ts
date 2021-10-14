import {Component, OnInit, ViewChild} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HttpClient, HttpParams} from "@angular/common/http";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {MatTableDataSource} from "@angular/material/table";
import {MatPaginator, PageEvent} from "@angular/material/paginator";
import {DatePipe} from "@angular/common";

export interface Page {
  id?:number;
  title?:string;
  content?:string;
  isDeleted?:boolean;
  isPublicated?:boolean;
  isGroup?:boolean;
  projectId?:number | null;
  project?:any;
  workPackageId?:number | null;
  workPackage?:any;
  parentId?:number | null;
  parent?:any;
  authorId?:number | null;
  author?:any;
  createdOn?:string;
  updatedOn?:string;
}

export class Paginator {
  page:number = 0;
  size:number = 20;
  totalElements:number = 0;
  totalPages:number = 0;
}

@Component({
  selector: 'op-pages',
  templateUrl: './pages.component.html',
  styleUrls: ['./pages.component.sass'],
})
export class PagesComponent implements OnInit {
  pages:Page[];
  public columns:[];
  displayedColumns:string[] = ['title', 'project', 'workPackage', 'author', 'created', 'published'];
  dataSource = new MatTableDataSource<Page>();
  paginatorSettings = new Paginator();

  @ViewChild(MatPaginator) paginator:MatPaginator;

  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    public datePipe:DatePipe,
  ) {
  }

  ngOnInit():void {
    this.getPages();
    //this.dataSource.paginator = this.paginator;
  }

  private getPages(size?:number, index?:number) {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/pages',
      {
        params: new HttpParams()
          .set('size', size ? size.toString() : '20')
          .set('page', index ? index.toString() : '0')
      })
      .toPromise()
      .then((pages:HalResource) => {
        this.pages = pages._embedded.pages;
        this.paginatorSettings = pages.page;
        this.dataSource.data = this.pages;
      })
      .catch((reason) => console.error(reason));
  }

  pageChanged(event:PageEvent) {
    this.getPages(event.pageSize, event.pageIndex);
  }
}

DynamicBootstrapper.register({selector: 'op-pages', cls: PagesComponent});
