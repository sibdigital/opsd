import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";
import {Component, Inject, OnInit, ViewChild} from "@angular/core";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {MatTableDataSource} from "@angular/material/table";
import {Paginator} from "core-components/pages/pages.component";
import {MatPaginator, PageEvent} from "@angular/material/paginator";
// import {SelectionModel} from "@angular/cdk/collections";


@Component({
  selector: 'select-organization-dialog',
  templateUrl: 'select-organization-dialog.html',
  styleUrls: ['select-organization-dialog.sass']
})
export class SelectOrganizationDialog implements OnInit {
  organizations: any;
  public columns: [];
  displayedColumns: string[] = ['id', 'name'];
  // displayedColumns: string[] = ['select','id', 'name'];
  dataSource = new MatTableDataSource();
  // selection = new SelectionModel<any>(true, []);
  passedValue = null;
  paginatorSettings = new Paginator();
  selectedOrganization = {id: null};
  @ViewChild(MatPaginator) paginator: MatPaginator;

  constructor(protected dialogRef: MatDialogRef<SelectOrganizationDialog>,
              @Inject(MAT_DIALOG_DATA) protected data: any,
              protected pathHelper: PathHelperService,
              protected httpClient: HttpClient) {
    this.organizations = this.data.items;
    this.dataSource.data = this.organizations;
    this.paginatorSettings.size = 10;
    this.passedValue = this.data.passedValue;
  }

  ngOnInit(): void {
    if (this.passedValue!=null){
      this.rowSelected(this.passedValue);
      // this.selection.select(this.passedValue);
    }
  }

  ngAfterViewInit() {
    this.dataSource.paginator = this.paginator;
  }

  rowSelected(row: any) {
    if (this.selectedOrganization==row){
      // this.selection.clear();
      this.selectedOrganization = {id: null};
    }
    else {
    // this.selection.clear();
    // this.selection.select(row);
    this.selectedOrganization = row;
    }
  }
}
