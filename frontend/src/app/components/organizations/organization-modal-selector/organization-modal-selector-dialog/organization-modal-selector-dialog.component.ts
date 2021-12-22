import {Component, Inject, OnInit, ViewChild} from '@angular/core';
import {MatPaginator} from "@angular/material/paginator";
import {MatSort} from "@angular/material/sort";
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";
import {merge, of as observableOf} from "rxjs";
import {catchError, map, startWith, switchMap} from "rxjs/operators";
import {MatRow} from "@angular/material/table";
import {Organization} from "core-components/organizations/organization.model";
import {OrganizationService} from "core-components/organizations/shared/organization.service";

@Component({
  selector: 'op-organization-modal-selector-dialog',
  templateUrl: './organization-modal-selector-dialog.component.html',
  styleUrls: ['./organization-modal-selector-dialog.component.sass']
})
export class OrganizationModalSelectorDialogComponent implements OnInit {

  displayedColumns:string[] = ['id', 'name'];
  organizations:Organization[] = [];
  keyWord:string = '';
  isLoadingResults = true;
  isRateLimitReached = false;
  @ViewChild(MatPaginator)  paginator!:MatPaginator;
  @ViewChild(MatSort) sort:MatSort = new MatSort;

  constructor(
    public dialogRef:MatDialogRef<OrganizationModalSelectorDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data:any,
    private organizationService:OrganizationService
  ) {
  }

  ngOnInit():void {
    this.dialogRef.updateSize('80%');
  }

  ngAfterViewInit() {
    // If the user changes the sort order, reset back to the first page.
    this.sort.sortChange.subscribe(() => this.paginator.pageIndex = 0);

    merge(this.sort.sortChange, this.paginator.page)
      .pipe(
        startWith({}),
        switchMap(() => {
          this.isLoadingResults = true;
          return this.organizationService.getAllByNameAndIsApproveAndPageAndSizeAndSort(
            this.keyWord, true, this.paginator.pageIndex, this.paginator.pageSize, this.sort.active, this.sort.direction)
            .pipe(catchError(() => observableOf(null)));
        }),
        map((data:any) => {
          // Flip flag to show that loading has finished.
          this.isLoadingResults = false;
          this.isRateLimitReached = data.page.number === data.page.totalPages;

          if (data === null) {
            return [];
          }

          // Only refresh the result length if there is new data. In case of rate
          // limit errors, we do not want to reset the paginator to zero, as that
          // would prevent users from re-triggering requests.
          // this.resultsLength = data.page.totalPages;
          this.paginator.length = data.page.totalElements;
          return data._embedded.organizations;
        })
      ).subscribe(data => {
      this.organizations = data;
      });

  }

  keyWordChange(event:Event) {
    this.keyWord = (event.target as HTMLInputElement).value;
    this.paginator.pageIndex = 0;
    this.ngAfterViewInit();
  }

  selectTarget(row:MatRow) {
    this.dialogRef.close({data: row});
  }
  closeDialog() {
    this.dialogRef.close();
  }

}
