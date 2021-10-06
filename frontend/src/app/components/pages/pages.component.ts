import {Component, OnInit} from "@angular/core";
import {FormControl} from "@angular/forms";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {IProjectsState, IProjectsTableColumn} from "core-components/projects/state/projects.state";
import {HttpClient, HttpParams} from "@angular/common/http";
import {ProjectsTablePaginationService} from "core-components/projects-table/projects-table-pagination.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {appBaseSelector, ApplicationBaseComponent} from "core-app/modules/router/base/application-base.component";

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

@Component({
  selector: 'op-pages',
  templateUrl: './pages.component.html',
  styleUrls: ['./pages.component.sass'],
})
export class PagesComponent implements OnInit {
  pages:Page[];
  public columns:[];
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    // public paginationService:ProjectsTablePaginationService,
  ) {}

  ngOnInit():void {
    this.getPages();
    // this.getProjects();
    // this.getGroups();
  }

  private getPages() {
    this.httpClient.get(
        this.pathHelper.javaApiPath.javaApiBasePath + '/pages').toPromise()
        .then((pages:HalResource) => {
          this.pages = pages._embedded.pages;
        })
        .catch((reason) => console.error(reason));
  }
  // public onChangePage(pageNumber:number) {
  //   console.dir({ projectsTable: pageNumber });
  //   this.paginationService.setCurrentPageParams({ page: pageNumber });
  // }
  //
  // public onChangePerPage(perPageSize:number) {
  //   console.dir({ perPageSize: perPageSize });
  //   this.paginationService.setPerPageSizeParams({ size: perPageSize, page: 0 });
  // }
}
DynamicBootstrapper.register({ selector: 'op-pages', cls: PagesComponent });
