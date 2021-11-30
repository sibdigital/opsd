import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";
import {Component, Inject, OnInit} from "@angular/core";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {MatTableDataSource} from "@angular/material/table";
import {Paginator} from "core-components/pages/pages.component";
import {PageEvent} from "@angular/material/paginator";

@Component({
  selector: 'select-work-package-dialog',
  templateUrl: 'select-work-package-dialog.html',
  styleUrls: ['select-work-package-dialog.sass']
})
export class SelectWorkPackageDialog implements OnInit {
  private project:any;
  workPackages:any;
  public columns:[];
  displayedColumns:string[] = ['subject', 'author', 'description'];
  dataSource = new MatTableDataSource();
  paginatorSettings = new Paginator();
  selectedWorkPackage = {id:null};
  constructor(protected dialogRef:MatDialogRef<SelectWorkPackageDialog>,
              @Inject(MAT_DIALOG_DATA) protected data:any,
              protected pathHelper:PathHelperService,
              protected httpClient:HttpClient) {
    this.project = this.data.project;
  }

  private loadWorkPackages(size?:number, index?:number) {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/workPackages/search/findWorkPackagesByProject_Id',
      {
        params: new HttpParams()
          .set("projectId", this.project.id)
          .set('size', size ? size.toString() : '5')
          .set('page', index ? index.toString() : '0')
      })
      .toPromise()
      .then((workPackages:any) => {
        this.workPackages = workPackages._embedded.workPackages;
        this.paginatorSettings = workPackages.page;
        this.dataSource.data = this.workPackages;
      })
      .catch((reason) => console.error(reason));
  }

  pageChanged(event:PageEvent) {
    this.selectedWorkPackage = {id: null};
    this.loadWorkPackages(event.pageSize, event.pageIndex);
  }

  ngOnInit():void {
    this.loadWorkPackages();
  }

  rowSelected(row:any) {
    this.selectedWorkPackage = row;
  }
}
